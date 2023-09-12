class User < ApplicationRecord
  has_one :author, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :rememberable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :timeoutable, :validatable, :confirmable

  protected

  # Override method to allow users to set up password after email confirmation
  def password_required?
    confirmed? ? super : false
  end
end
