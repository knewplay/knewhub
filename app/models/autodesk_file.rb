class AutodeskFile < ApplicationRecord
  belongs_to :repository

  validates :urn, presence: true
  validates :filepath, presence: true
end
