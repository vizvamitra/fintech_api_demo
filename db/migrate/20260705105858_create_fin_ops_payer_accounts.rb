class CreateFinOpsPayerAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :fin_ops_payer_accounts do |t|
      t.uuid :client_id, null: false, index: { unique: true }
      t.string :available_funds_account, null: false, index: { unique: true }
      t.string :reserved_funds_account, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
