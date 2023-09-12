class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.references :build, foreign_key: true
      t.text :content
      t.timestamps
    end
  end
end
