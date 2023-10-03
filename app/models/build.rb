class Build < ApplicationRecord
  include AASM

  belongs_to :repository
  has_many :logs, dependent: :destroy, after_add: %i[verify_complete verify_failed]

  validates :status, presence: true
  validates :action, presence: true

  def repository_name
    repository.name
  end

  def repository_author
    repository.author.name
  end

  def current_step
    unique_logs = logs.select(:step).distinct
    # Background jobs can create duplicates of a log or can result in logs being created out of order
    unique_logs.count
  end

  def max_step
    MAX_LOG_STEPS[action.to_sym]
  end

  aasm do
    state :initiated, initial: true
    state :creating_webhook,
          :testing_webhook,
          :cloning_repo,
          :pulling_repo,
          :getting_repo_description,
          :parsing_questions,
          :creating_repo_index,
          :completed

    event :create_webhook, after_commit: :schedule_create_webhook do
      transitions from: :initiated, to: :creating_webhook
    end

    event :test_webhook, after_commit: :schedule_test_webhook do
      transitions from: :creating_webhook, to: :testing_webhook
    end

    event :clone_repo, after_commit: :schedule_clone_repo do
      transitions from: :initiated, to: :cloning_repo
    end

    event :pull_repo, after_commit: :schedule_pull_repo do
      transitions from: :initiated, to: :pulling_repo
    end

    event :get_repo_description, after_commit: :schedule_get_repo_description do
      transitions from: :pulling_repo, to: :getting_repo_description
    end

    event :parse_questions, after_commit: :schedule_parse_questions do
      transitions from: :getting_repo_description, to: :parsing_questions
    end

    event :create_repo_index, after_commit: :schedule_create_repo_index do
      transitions from: :parsing_questions, to: :creating_repo_index
    end

    event :complete do
      transitions from: :creating_repo_index, to: :completed
    end
  end

  # AASM: initiate event
  def create_repo
    create_webhook!
  end

  def rebuild_repo
    pull_repo!
  end

  def update_repo(git_action)
    case git_action
    when 'clone'
      clone_repo!
    when 'pull'
      pull_repo!
    end
  end

  # AASM: call background jobs
  def schedule_create_webhook
    CreateGithubWebhookJob.perform_async(repository.id, id)
  end

  def schedule_test_webhook
    TestGithubWebhook.perform_async(repository.id, id)
  end

  def schedule_clone_repo
    CloneGithubRepoJob.perform_async(repository.id, id)
  end

  def schedule_pull_repo
    PullGithubRepoJob.perform_async(repository.id, id)
  end

  def schedule_get_repo_description
    GetGithubDescriptionJob.perform_async(repository.id, id)
  end

  def schedule_parse_questions
    ParseQuestionsJob.perform_async(repository.id, id)
  end

  def schedule_create_repo_index
    CreateRepoIndexJob.perform_async(repository.id, id)
  end

  # AASM: notifications of jobs completion
  def finished_creating_webhook
    test_webhook!
  end

  def finished_testing_webhook
    clone_repo!
  end

  def finished_cloning_repo
    get_repo_description!
  end

  def finished_pulling_repo
    get_repo_description!
  end

  def finished_getting_repo_description
    parse_questions!
  end

  def finished_parsing_questions
    create_repo_index!
  end

  def finished_creating_repo_index
    complete!
  end

  private

  MAX_LOG_STEPS = {
    create: 6,
    update: 4,
    rebuild: 4,
    webhook_push: 5
  }.freeze

  # `latest_log` is passed as an argument when using the `after_add` callback
  # But it is not required
  def verify_complete(_latest_log = nil)
    return unless no_failures? && max_steps_reached?

    update(status: 'Complete', completed_at: DateTime.current)
  end

  def verify_failed(_latest_log = nil)
    update(status: 'Failed', completed_at: DateTime.current) if logs.any? { |log| log.failure == true }
  end

  def max_steps_reached?
    current_step == max_step
  end

  def no_failures?
    logs.none? { |log| log.failure == true }
  end
end
