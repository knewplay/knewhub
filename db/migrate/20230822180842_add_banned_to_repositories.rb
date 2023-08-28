class AddBannedToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :banned, :boolean, default: false
  end
end
