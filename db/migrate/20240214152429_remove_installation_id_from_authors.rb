class RemoveInstallationIdFromAuthors < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :authors, :installation_id, :string }
  end
end
