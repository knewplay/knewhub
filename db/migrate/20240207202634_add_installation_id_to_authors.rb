class AddInstallationIdToAuthors < ActiveRecord::Migration[7.1]
  def change
    add_column :authors, :installation_id, :string
  end
end
