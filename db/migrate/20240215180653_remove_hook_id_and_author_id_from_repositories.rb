class RemoveHookIdAndAuthorIdFromRepositories < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_reference :repositories, :author }
    safety_assured { remove_column :repositories, :hook_id, :integer }
  end
end
