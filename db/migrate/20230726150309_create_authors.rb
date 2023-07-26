class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :github_uid
      t.string :github_username
      t.timestamps
    end
  end
end
