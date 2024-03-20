class AutodeskFile < ApplicationRecord
  belongs_to :repository

  validates :filepath, presence: true

  delegate :name, to: :repository, prefix: true
end
