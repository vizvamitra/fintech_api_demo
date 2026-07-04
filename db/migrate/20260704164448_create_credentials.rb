# frozen_string_literal: true

class CreateCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :credentials do |t|
      t.string :email, null: false, index: { unique: true }

      t.timestamps null: false
    end
  end
end
