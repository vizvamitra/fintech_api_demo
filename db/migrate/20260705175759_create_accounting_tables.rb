class CreateAccountingTables < ActiveRecord::Migration[8.1]
  def change
    create_table :accounting_accounts do |t|
      t.uuid :client_id, index: true
      t.integer :category, limit: 2, null: false, index: true
      t.integer :natural_balance, limit: 2, null: false
      t.string :label, null: false, index: { unique: true }
      t.string :code, null: false
      t.string :owner_ref

      t.timestamps

      t.check_constraint "natural_balance IN (1, -1)"
    end

    create_table :accounting_postings do |t|
      t.references :account, null: false, index: true
      t.references :journal_entry, null: false, index: true
      t.bigint :amount_cents, null: false
      t.integer :side, limit: 2, null: false, index: true

      t.datetime :created_at, null: false, default: "NOW()"

      t.check_constraint "amount_cents > 0"
      t.check_constraint "side IN (1, -1)"
    end

    create_table :accounting_journal_entries do |t|
      t.string :description, null: false
      t.string :reference_type, null: false
      t.string :reference_id, null: false
      t.string :idempotency_key, null: false, index: { unique: true }
      t.datetime :effective_at, null: false

      t.datetime :created_at, null: false, default: "NOW()"
    end
  end
end
