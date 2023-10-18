class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  has_many :likes, dependent: :destroy

  validates :body, presence: true
  validates_uniqueness_of :user_id, scope: :question_id, message: 'can only have one answer per question'

  def liked_by_user(user)
    likes.find { |like| like.user == user }
  end
end
