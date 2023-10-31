class Like < ApplicationRecord
  belongs_to :user
  belongs_to :answer

  validates :user_id, uniqueness: { scope: :answer_id, message: 'can only like an answer once' }
end
