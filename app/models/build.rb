class Build < ApplicationRecord
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
