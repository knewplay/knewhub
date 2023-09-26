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

  # { action: logs.count }
  COMPLETE_MATRIX = {
    create: 5,
    update: 3,
    rebuild: 3,
    webhook_push: 4
  }.freeze

  # `latest_log` is passed as an argument when using the `after_add` callback
  # But it is not required
  def verify_complete(_latest_log = nil)
    return unless no_failures? && logs.count == max_log_count

    update(status: 'Complete', completed_at: DateTime.current)
  end

  def no_failures?
    logs.none? { |log| log.failure == true }
  end

  def verify_failed(_latest_log = nil)
    update(status: 'Failed', completed_at: DateTime.current) if logs.any? { |log| log.failure == true }
  end

  def max_log_count
    COMPLETE_MATRIX[action.to_sym]
  end
end
