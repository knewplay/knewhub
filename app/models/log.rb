class Log < ApplicationRecord
  belongs_to :build

  validates :content, presence: true
  attribute :failure, :boolean, default: false
end
