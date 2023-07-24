class AddUuidToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :uuid, :uuid
  end
end
