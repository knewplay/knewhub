class RemoveRememberCreatedAt < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :remember_created_at
  end
end
