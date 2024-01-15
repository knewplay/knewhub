class RemoveStepFromLogs < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :logs, :step }
  end
end
