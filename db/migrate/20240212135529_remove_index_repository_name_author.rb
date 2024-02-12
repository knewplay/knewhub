class RemoveIndexRepositoryNameAuthor < ActiveRecord::Migration[7.1]
  def change
    remove_index :repositories, column: %i[name author_id]
  end
end
