class User < ApplicationRecord
  has_one :author, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :rememberable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :timeoutable, :validatable, :confirmable

  protected

  # Override method to allow users to set up password after email confirmation
  def password_required?
    confirmed? ? super : false
  end

  # Override method to send e-mail using background job
  def send_devise_notification(notification, *)
    message = devise_mailer.send(notification, self, *)
    message.deliver_later
  end
end
