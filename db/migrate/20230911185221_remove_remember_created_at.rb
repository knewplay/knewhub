class RemoveRememberCreatedAt < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :users, :remember_created_at }
  end
end
