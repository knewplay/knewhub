class CreateGithubInstallations < ActiveRecord::Migration[7.1]
  def change
    create_table :github_installations do |t|
      t.references :author, foreign_key: true
      t.string :uid
      t.string :username
      t.string :installation_id
      t.timestamps
    end
  end
end
