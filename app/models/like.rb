class Like < ApplicationRecord
  belongs_to :user
  belongs_to :answer

  validates_uniqueness_of :user_id, scope: :answer_id, message: 'can only like an answer once'
end
