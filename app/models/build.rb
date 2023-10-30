class Build < ApplicationRecord
  include AASM

  belongs_to :repository
  has_many :logs, dependent: :destroy, after_add: :verify_failed

  validates :status, presence: true
  validates :action, presence: true

  delegate :name, to: :repository, prefix: true

  def repository_author
    repository.author.name
  end

  aasm do
    state :initiated, initial: true
    state :creating_webhook,
          :testing_webhook,
          :receiving_webhook,
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

    event :receive_webhook, after_commit: :schedule_receive_webhook do
      transitions from: :initiated, to: :receiving_webhook
    end

    event :clone_repo, after_commit: :schedule_clone_repo do
      transitions from: %i[initiated receiving_webhook testing_webhook], to: :cloning_repo
    end

    event :pull_repo, after_commit: :schedule_pull_repo do
      transitions from: %i[initiated receiving_webhook], to: :pulling_repo
    end

    event :get_repo_description, after_commit: :schedule_get_repo_description do
      transitions from: %i[cloning_repo pulling_repo], to: :getting_repo_description
    end

    event :parse_questions, after_commit: :schedule_parse_questions do
      transitions from: %i[cloning_repo pulling_repo getting_repo_description], to: :parsing_questions
    end

    event :create_repo_index, after_commit: :schedule_create_repo_index do
      transitions from: :parsing_questions, to: :creating_repo_index
    end

    event :complete, after_commit: :complete_build do
      transitions from: :creating_repo_index, to: :completed
    end
  end

  # AASM: initiate event
  def create_repo
    create_webhook!
  end

  def receive_webhook_push(uuid, name, owner_name, description)
    receive_webhook!(uuid, name, owner_name, description)
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

  # AASM: callbacks
  def schedule_create_webhook
    CreateGithubWebhookJob.perform_async(id)
  end

  def schedule_test_webhook
    # Wait a few seconds for the webhook to be created on GitHub's end
    TestGithubWebhookJob.perform_in(10.seconds, id)
  end

  def schedule_receive_webhook(uuid, name, owner_name, description)
    RespondWebhookPushJob.perform_async(id, uuid, name, owner_name, description)
  end

  def schedule_clone_repo
    CloneGithubRepoJob.perform_async(id)
  end

  def schedule_pull_repo
    PullGithubRepoJob.perform_async(id)
  end

  def schedule_get_repo_description
    GetGithubDescriptionJob.perform_async(id)
  end

  def schedule_parse_questions
    ParseQuestionsJob.perform_async(id)
  end

  def schedule_create_repo_index
    CreateRepoIndexJob.perform_async(id)
  end

  def complete_build
    update(status: 'Complete', completed_at: DateTime.current)
  end

  # AASM: notifications of jobs completion
  def finished_creating_webhook
    test_webhook!
  end

  def finished_testing_webhook
    clone_repo!
  end

  def finished_receiving_webhook(git_action)
    case git_action
    when 'clone'
      clone_repo!
    when 'pull'
      pull_repo!
    end
  end

  def finished_cloning_or_pulling_repo
    if action == 'webhook_push'
      parse_questions!
    else
      get_repo_description!
    end
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

  # `latest_log` is passed as an argument when using the `after_add` callback
  # But it is not required
  def verify_failed(_latest_log = nil)
    update(status: 'Failed', completed_at: DateTime.current) if logs.any? { |log| log.failure == true }
  end
end
