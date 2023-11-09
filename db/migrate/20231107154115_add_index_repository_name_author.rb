class AddIndexRepositoryNameAuthor < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :repositories, %i[name author_id], unique: true, algorithm: :concurrently
  end
end
