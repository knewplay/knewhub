class ReplaceUuidByUidInRepositories < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :repositories, :uuid, :uuid }
    add_column :repositories, :uid, :bigint
  end
end
