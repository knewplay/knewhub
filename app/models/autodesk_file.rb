class AutodeskFile < ApplicationRecord
  belongs_to :repository

  validates :filepath, presence: true
end
