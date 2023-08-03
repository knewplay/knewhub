class CreateAdministrators < ActiveRecord::Migration[7.0]
  def change
    create_table :administrators do |t|
      t.string :name
      t.string :password_digest
      t.string :permissions, default: 'admin'
      t.timestamps
    end
  end
end
