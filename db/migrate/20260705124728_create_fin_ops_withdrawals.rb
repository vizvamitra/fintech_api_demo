class CreateFinOpsWithdrawals < ActiveRecord::Migration[8.1]
  def change
    create_table :fin_ops_withdrawals do |t|
      t.references :payer, null: false, index: true
      t.uuid :public_id, null: false, default: "uuid_generate_v4()"
      t.integer :amount_cents, null: false
      t.integer :state, null: false, default: 1
      t.datetime :settled_at

      t.timestamps

      t.index :public_id, unique: true
    end
  end
end
