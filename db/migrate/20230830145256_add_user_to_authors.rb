class AddUserToAuthors < ActiveRecord::Migration[7.0]
  def change
    add_reference :authors, :user, index: { unique: true }, foreign_key: true
  end
end
