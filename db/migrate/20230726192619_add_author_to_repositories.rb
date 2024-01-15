class AddAuthorToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_reference :repositories, :author, foreign_key: true
    safety_assured { remove_column :repositories, :owner }
  end
end
