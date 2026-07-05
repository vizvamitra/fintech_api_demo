class CreateCXMoneyMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :cx_money_movements do |t|
      t.references :client, null: false, index: true
      t.references :sender, index: true
      t.integer :kind, limit: 2, null: false
      t.uuid :reference, null: false
      t.integer :amount_cents, null: false
      t.integer :state, limit: 2, null: false, default: 1
      t.datetime :initiated_at, null: false
      t.datetime :resolved_at
      t.string :error

      t.timestamps

      t.index %i[client_id kind]
      t.index %i[client_id initiated_at]
      t.index %i[client_id reference], unique: true
    end
  end
end
