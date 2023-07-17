class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :owner
      t.string :name
      t.string :token
      t.string :git_url
      t.string :branch
      t.string :description
      t.datetime :last_pull_at
      t.timestamps
    end
  end
end
