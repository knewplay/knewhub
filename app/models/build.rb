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
    log_at_max_step = logs.order('step DESC').first
    log_at_max_step&.step
  end

  def max_step
    MAX_LOG_STEPS[action.to_sym]
  end

  private

  MAX_LOG_STEPS = {
    create: 5,
    update: 3,
    rebuild: 3,
    webhook_push: 4
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
