class Build < ApplicationRecord
  include AASM

  belongs_to :repository
  has_many :logs, dependent: :destroy, after_add: :verify_failed

  validates :status, presence: true
  validates :action, presence: true

  delegate :name, to: :repository, prefix: true

  aasm do
    state :initiated, initial: true
    state :receiving_webhook,
          :cloning_repo,
          :pulling_repo,
          :getting_repo_description,
          :parsing_questions,
          :creating_repo_index,
          :uploading_autodesk_files,
          :completed

    event :receive_webhook, after_commit: :schedule_receive_webhook do
      transitions from: :initiated, to: :receiving_webhook
    end

    event :clone_repo, after_commit: :schedule_clone_repo do
      transitions from: %i[initiated receiving_webhook], to: :cloning_repo
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

    event :upload_autodesk_files, after_commit: :schedule_upload_autodesk_files do
      transitions from: :creating_repo_index, to: :uploading_autodesk_files
    end

    event :complete, after_commit: :complete_build do
      transitions from: :uploading_autodesk_files, to: :completed
    end
  end

  # AASM: initiate event
  def create_repo
    clone_repo!
  end

  def receive_webhook_push(uid, name, owner_name, description)
    receive_webhook!(uid, name, owner_name, description)
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
  def schedule_receive_webhook(uid, description)
    RespondWebhookPushJob.perform_async(id, uid, description)
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

  def schedule_upload_autodesk_files
    UploadAutodeskFilesJob.perform_async(id)
  end

  def complete_build
    update(status: 'Complete', completed_at: DateTime.current)
  end

  # AASM: notifications of jobs completion
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
    upload_autodesk_files!
  end

  def finished_uploading_autodesk_files
    complete!
  end

  private

  # `latest_log` is passed as an argument when using the `after_add` callback
  # But it is not required
  def verify_failed(_latest_log = nil)
    update(status: 'Failed', completed_at: DateTime.current) if logs.any? { |log| log.failure == true }
  end
end
