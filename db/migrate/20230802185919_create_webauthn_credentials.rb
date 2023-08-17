class CreateWebauthnCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :webauthn_credentials do |t|
      t.references :administrator, foreign_key: true
      t.string :external_id
      t.string :public_key
      t.string :nickname
      t.bigint :sign_count, default: 0
      t.timestamps

      t.index :external_id, unique: true
    end
  end
end
