class CreateCXCustomers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "uuid-ossp"

    create_table :cx_customers do |t|
      t.uuid :public_id, null: false, default: "uuid_generate_v4()"
      t.string :public_email, null: false

      t.timestamps

      t.index :public_id, unique: true
      t.index :public_email, unique: true
    end

    add_column :credentials, :customer_id, :uuid
    add_index :credentials, :customer_id, unique: true
  end
end
