class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :answer, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_index :likes, %i[user_id answer_id], unique: true
  end
end
