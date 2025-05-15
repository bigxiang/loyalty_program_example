# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_15_050645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "whitelisted_ips", default: [], array: true
    t.index ["client_id"], name: "index_api_keys_on_client_id"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clients_on_name", unique: true
  end

  create_table "end_user_accounts", force: :cascade do |t|
    t.bigint "end_user_id", null: false
    t.bigint "client_id", null: false
    t.integer "level", null: false
    t.integer "current_points", null: false
    t.integer "total_spent_in_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "end_user_id"], name: "index_end_user_accounts_on_client_id_and_end_user_id", unique: true
    t.index ["client_id"], name: "index_end_user_accounts_on_client_id"
    t.index ["end_user_id"], name: "index_end_user_accounts_on_end_user_id"
  end

  create_table "end_user_rewards", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "end_user_id", null: false
    t.bigint "reward_rule_id", null: false
    t.datetime "issued_at", precision: nil, null: false
    t.string "issurance_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "issurance_identifier"], name: "index_end_user_rewards_on_client_id_and_issurance_identifier", unique: true
    t.index ["client_id"], name: "index_end_user_rewards_on_client_id"
    t.index ["end_user_id"], name: "index_end_user_rewards_on_end_user_id"
    t.index ["reward_rule_id"], name: "index_end_user_rewards_on_reward_rule_id"
  end

  create_table "end_user_transactions", force: :cascade do |t|
    t.string "transaction_identifier", null: false
    t.bigint "end_user_id", null: false
    t.bigint "client_id", null: false
    t.boolean "is_foreign", null: false
    t.integer "amount_in_cents", null: false
    t.integer "points_earned", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "transaction_identifier"], name: "idx_on_client_id_transaction_identifier_5969db325c", unique: true
    t.index ["client_id"], name: "index_end_user_transactions_on_client_id"
    t.index ["end_user_id"], name: "index_end_user_transactions_on_end_user_id"
  end

  create_table "end_users", force: :cascade do |t|
    t.string "identifier", null: false
    t.bigint "client_id", null: false
    t.date "birthday", null: false
    t.datetime "registered_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "identifier"], name: "index_end_users_on_client_id_and_identifier", unique: true
    t.index ["client_id"], name: "index_end_users_on_client_id"
  end

  create_table "point_rules", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name"
    t.integer "level"
    t.jsonb "conditions"
    t.jsonb "actions"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_point_rules_on_client_id"
  end

  create_table "reward_rules", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name", null: false
    t.integer "level", null: false
    t.jsonb "conditions", null: false
    t.jsonb "actions", null: false
    t.jsonb "repeat_condition", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "name"], name: "index_reward_rules_on_client_id_and_name", unique: true
    t.index ["client_id"], name: "index_reward_rules_on_client_id"
  end

  add_foreign_key "api_keys", "clients"
  add_foreign_key "end_user_accounts", "clients"
  add_foreign_key "end_user_accounts", "end_users"
  add_foreign_key "end_user_rewards", "clients"
  add_foreign_key "end_user_rewards", "end_users"
  add_foreign_key "end_user_rewards", "reward_rules"
  add_foreign_key "end_user_transactions", "clients"
  add_foreign_key "end_user_transactions", "end_users"
  add_foreign_key "end_users", "clients"
  add_foreign_key "point_rules", "clients"
  add_foreign_key "reward_rules", "clients"
end
