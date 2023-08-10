class Administrator < ApplicationRecord
  has_secure_password

  has_many :webauthn_credentials, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, on: :create
  validates :permissions, presence: true

  def multi_factor_enabled?
    webauthn_credentials.any?
  end
end
