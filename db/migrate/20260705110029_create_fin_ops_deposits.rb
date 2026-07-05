class CreateFinOpsDeposits < ActiveRecord::Migration[8.1]
  def change
    create_table :fin_ops_deposits do |t|
      t.references :payer, null: false
      t.uuid :public_id, null: false, default: "uuid_generate_v4()"
      t.integer :amount_cents, null: false

      t.timestamps
    end
  end
end
