class CreateEndUserRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :end_user_rewards do |t|
      t.belongs_to :client, null: false, foreign_key: true
      t.belongs_to :end_user, null: false, foreign_key: true
      t.belongs_to :reward_rule, null: false, foreign_key: true
      t.timestamp :issued_at, null: false
      t.string :transaction_identifier, null: false

      t.timestamps

      t.index [ :client_id, :transaction_identifier ], unique: true
    end
  end
end
