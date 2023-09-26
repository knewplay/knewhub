class AddStepToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :step, :integer
  end
end
