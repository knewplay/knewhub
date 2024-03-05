class CreateAutodeskFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :autodesk_files do |t|
      t.references :repository, foreign_key: true
      t.string :urn
      t.string :filepath
      t.timestamps
    end
  end
end
