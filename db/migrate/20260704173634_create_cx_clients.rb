class CreateCXClients < ActiveRecord::Migration[8.1]
  def change
    enable_extension "uuid-ossp"

    create_table :cx_clients do |t|
      t.uuid :public_id, null: false, default: "uuid_generate_v4()"
      t.string :contact_email

      t.timestamps

      t.index :public_id, unique: true
    end

    add_column :credentials, :client_id, :uuid
    add_index :credentials, :client_id, unique: true
  end
end
