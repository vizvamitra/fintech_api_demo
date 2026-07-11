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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_175759) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounting_accounts", force: :cascade do |t|
    t.integer "category", limit: 2, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.uuid "customer_id"
    t.string "label", null: false
    t.integer "natural_balance", limit: 2, null: false
    t.string "owner_ref"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_accounting_accounts_on_category"
    t.index ["customer_id"], name: "index_accounting_accounts_on_customer_id"
    t.index ["label"], name: "index_accounting_accounts_on_label", unique: true
    t.check_constraint "natural_balance = ANY (ARRAY[1, '-1'::integer])"
  end

  create_table "accounting_journal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.datetime "effective_at", null: false
    t.string "idempotency_key", null: false
    t.string "reference_id", null: false
    t.string "reference_type", null: false
    t.index ["idempotency_key"], name: "index_accounting_journal_entries_on_idempotency_key", unique: true
  end

  create_table "accounting_postings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "journal_entry_id", null: false
    t.integer "side", limit: 2, null: false
    t.index ["account_id"], name: "index_accounting_postings_on_account_id"
    t.index ["journal_entry_id"], name: "index_accounting_postings_on_journal_entry_id"
    t.index ["side"], name: "index_accounting_postings_on_side"
    t.check_constraint "amount_cents > 0"
    t.check_constraint "side = ANY (ARRAY[1, '-1'::integer])"
  end

  create_table "credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "customer_id"
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_credentials_on_customer_id", unique: true
    t.index ["email"], name: "index_credentials_on_email", unique: true
  end

  create_table "cx_customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_email", null: false
    t.uuid "public_id", default: -> { "uuid_generate_v4()" }, null: false
    t.datetime "updated_at", null: false
    t.index ["public_email"], name: "index_cx_customers_on_public_email", unique: true
    t.index ["public_id"], name: "index_cx_customers_on_public_id", unique: true
  end

  create_table "cx_money_movements", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "error"
    t.datetime "initiated_at", null: false
    t.integer "kind", limit: 2, null: false
    t.uuid "reference", null: false
    t.datetime "resolved_at"
    t.bigint "sender_id"
    t.integer "state", limit: 2, default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "initiated_at"], name: "index_cx_money_movements_on_customer_id_and_initiated_at"
    t.index ["customer_id", "kind"], name: "index_cx_money_movements_on_customer_id_and_kind"
    t.index ["customer_id", "reference"], name: "index_cx_money_movements_on_customer_id_and_reference", unique: true
    t.index ["customer_id"], name: "index_cx_money_movements_on_customer_id"
    t.index ["sender_id"], name: "index_cx_money_movements_on_sender_id"
  end

  create_table "fin_ops_deposits", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "payer_id", null: false
    t.uuid "public_id", default: -> { "uuid_generate_v4()" }, null: false
    t.datetime "updated_at", null: false
    t.index ["payer_id"], name: "index_fin_ops_deposits_on_payer_id"
  end

  create_table "fin_ops_payer_accounts", force: :cascade do |t|
    t.string "available_funds_account", null: false
    t.datetime "created_at", null: false
    t.uuid "customer_id", null: false
    t.string "reserved_funds_account", null: false
    t.datetime "updated_at", null: false
    t.index ["available_funds_account"], name: "index_fin_ops_payer_accounts_on_available_funds_account", unique: true
    t.index ["customer_id"], name: "index_fin_ops_payer_accounts_on_customer_id", unique: true
    t.index ["reserved_funds_account"], name: "index_fin_ops_payer_accounts_on_reserved_funds_account", unique: true
  end

  create_table "fin_ops_transfers", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.uuid "public_id", default: -> { "uuid_generate_v4()" }, null: false
    t.bigint "receiver_id", null: false
    t.bigint "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_fin_ops_transfers_on_receiver_id"
    t.index ["sender_id"], name: "index_fin_ops_transfers_on_sender_id"
  end

  create_table "fin_ops_withdrawals", force: :cascade do |t|
    t.bigint "amount_cents", null: false
    t.datetime "created_at", null: false
    t.bigint "payer_id", null: false
    t.uuid "public_id", default: -> { "uuid_generate_v4()" }, null: false
    t.datetime "settled_at"
    t.integer "state", limit: 2, default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["payer_id"], name: "index_fin_ops_withdrawals_on_payer_id"
    t.index ["public_id"], name: "index_fin_ops_withdrawals_on_public_id", unique: true
  end
end
