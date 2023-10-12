class Administrator < ApplicationRecord
  has_secure_password

  has_many :webauthn_credentials, dependent: :destroy

  validates :name,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-zA-Z0-9-]{0,39}\z/, message: 'can only contain alphanumeric characters and dashes' },
            length: { maximum: 39 }
  validates :password, length: { minimum: 6 }, on: :create
  validates :permissions, presence: true

  normalizes :name, with: ->(name) { name.strip.downcase }

  def multi_factor_enabled?
    webauthn_credentials.any?
  end
end
