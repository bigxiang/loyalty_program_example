class CreatePointRules < ActiveRecord::Migration[8.0]
  def change
    create_table :point_rules do |t|
      t.belongs_to :client, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :level, null: false
      t.jsonb :conditions, null: false
      t.jsonb :actions, null: false
      t.boolean :active, null: false, default: true

      t.timestamps

      t.index [ :client_id, :name ], unique: true
    end
  end
end
