class AddWebauthnIdToAdministrators < ActiveRecord::Migration[7.0]
  def change
    add_column :administrators, :webauthn_id, :string
  end
end
