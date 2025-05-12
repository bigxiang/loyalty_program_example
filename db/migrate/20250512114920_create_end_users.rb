class CreateEndUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :end_users do |t|
      t.string :identifier, null: false
      t.belongs_to :client, null: false, foreign_key: true
      t.date :birthday, null: false
      t.timestamp :registered_at, null: false

      t.timestamps

      t.index [ :client_id, :identifier ], unique: true
    end
  end
end
