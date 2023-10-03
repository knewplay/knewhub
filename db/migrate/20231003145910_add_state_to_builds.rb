class AddStateToBuilds < ActiveRecord::Migration[7.0]
  def change
    add_column :builds, :aasm_state, :string
  end
end
