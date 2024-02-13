class AddGithubInstallationToRepositories < ActiveRecord::Migration[7.1]
  def change
    add_reference :repositories, :github_installation, foreign_key: true
  end
end
