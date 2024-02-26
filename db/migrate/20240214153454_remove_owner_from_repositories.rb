class RemoveOwnerFromRepositories < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :repositories, :owner, :string }
  end
end
