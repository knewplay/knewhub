class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user

  validates :body, presence: true
  validates_uniqueness_of :user_id, scope: :question_id, message: 'A user can only have one answer per question'
end
