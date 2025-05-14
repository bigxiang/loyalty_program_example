class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.belongs_to :client, null: false, foreign_key: true
      t.string :token_digest, null: false, index: { unique: true }
      t.timestamp :expires_at
      t.timestamp :revoked_at

      t.timestamps
    end
  end
end
