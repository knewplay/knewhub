class AddHookIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :hook_id, :integer
  end
end
