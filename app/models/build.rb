class Build < ApplicationRecord
  belongs_to :repository
  has_many :logs, dependent: :destroy

  validates :status, presence: true
end
