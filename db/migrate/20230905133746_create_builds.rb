class CreateBuilds < ActiveRecord::Migration[7.0]
  def change
    create_table :builds do |t|
      t.references :repository, foreign_key: true
      t.datetime :completed_at
      t.string :status
      t.timestamps
    end
  end
end
