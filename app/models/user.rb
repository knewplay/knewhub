class User < ApplicationRecord
  has_one :author, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Override method to set remember_me == true by default
  def remember_me
    super.nil? ? true : super
  end

  protected

  # Override method to allow users to set up password after email confirmation
  def password_required?
    confirmed? ? super : false
  end
end
