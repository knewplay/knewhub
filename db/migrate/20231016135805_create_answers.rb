class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.references :question, foreign_key: true
      t.references :user, foreign_key: true
      t.text :body
      t.timestamps
    end

    add_index :answers, %i[user_id question_id], unique: true
  end
end
