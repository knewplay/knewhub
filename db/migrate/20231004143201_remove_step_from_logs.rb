class RemoveStepFromLogs < ActiveRecord::Migration[7.0]
  def change
    remove_column :logs, :step
  end
end
