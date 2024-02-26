class AddIndexRepositoryNameOwner < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :repositories, %i[name owner], unique: true, algorithm: :concurrently
  end
end
