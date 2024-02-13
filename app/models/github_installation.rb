class GithubInstallation < ApplicationRecord
  belongs_to :author
  has_many :repositories, dependent: :destroy
end
