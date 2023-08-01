class AddTitleToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :title, :string
  end
end
