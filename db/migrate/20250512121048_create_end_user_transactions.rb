class CreateEndUserTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :end_user_transactions do |t|
      t.string :transaction_identifier, null: false
      t.belongs_to :end_user, null: false, foreign_key: true
      t.belongs_to :client, null: false, foreign_key: true
      t.boolean :is_foreign, null: false
      t.integer :amount_in_cents, null: false
      t.integer :points_earned, null: false

      t.timestamps

      t.index [ :client_id, :transaction_identifier ], unique: true
    end
  end
end
