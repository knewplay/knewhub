class AddActionToBuildsAndFailureToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :builds, :action, :string
    add_column :logs, :failure, :boolean, default: false
  end
end
