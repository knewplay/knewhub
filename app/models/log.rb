class Log < ApplicationRecord
  belongs_to :build

  validates :content, presence: true
end
