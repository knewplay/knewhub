class Question < ApplicationRecord
  belongs_to :repository

  validates :tag, presence: true
  validates :page_path, presence: true
  validates :body, presence: true
  validates :batch_code, presence: true
  attribute :hidden, :boolean, default: false
end
