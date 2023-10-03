class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.references :repository, foreign_key: true
      t.string :tag
      t.string :page_path
      t.text :body

      t.timestamps
    end
  end
end
