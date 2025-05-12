class CreateEndUserAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :end_user_accounts do |t|
      t.belongs_to :end_user, null: false, foreign_key: true
      t.belongs_to :client, null: false, foreign_key: true
      t.integer :level, null: false
      t.integer :current_points, null: false
      t.integer :monthly_points, null: false
      t.integer :total_spent_in_cents, null: false

      t.timestamps

      t.index [ :client_id, :end_user_id ], unique: true
    end
  end
end
