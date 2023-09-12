class Build < ApplicationRecord
  belongs_to :repository
  has_many :logs, dependent: :destroy, after_add: :verify_complete

  validates :status, presence: true
  validates :action, presence: true

  # { action: logs.count }
  COMPLETE_MATRIX = {
    create: 5,
    update: 3,
    rebuild: 3,
    webhook_ping: 1,
    webhook_push: 4
  }.freeze

  # `latest_log` is passed as an argument when using the `after_add` callback
  # But it is not required
  def verify_complete(_latest_log = nil)
    max_log_count = COMPLETE_MATRIX[action.to_sym]
    return unless no_failures? && logs.count == max_log_count

    update(status: 'Complete', completed_at: DateTime.current)
  end

  def no_failures?
    logs.none? { |log| log.failure == true }
  end

  def repository_name
    repository.name
  end

  def repository_author
    repository.author.name
  end
end
