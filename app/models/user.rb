class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  def remember_me
    super.nil? ? true : super
  end

  protected

  def password_required?
    confirmed? ? super : false
  end
end
