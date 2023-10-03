class Question < ApplicationRecord
  belongs_to :repository

  validates :tag, presence: true
  validates :page_path, presence: true
  validates :body, presence: true
end
