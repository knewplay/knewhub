class AddIndexForUniqueness < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :administrators, :name, unique: true, algorithm: :concurrently
    add_index :authors, :github_uid, unique: true, algorithm: :concurrently
    add_index :authors, :github_username, unique: true, algorithm: :concurrently
  end
end
