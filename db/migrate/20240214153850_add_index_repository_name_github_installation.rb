class AddIndexRepositoryNameGithubInstallation < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :repositories, %i[name github_installation_id], unique: true, algorithm: :concurrently
  end
end
