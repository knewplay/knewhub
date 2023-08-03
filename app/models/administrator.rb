class Administrator < ApplicationRecord
  has_secure_password

  has_many :webauthn_credentials, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
  validates :permissions, presence: true
end
