# frozen_string_literal: true

class CreateDeposits < ActiveRecord::Migration[5.1]
  def change
    create_table :deposits do |t|
      t.string :artifact_id, null: false, index: false
      t.belongs_to :user, null: false, index: false
      t.string :status, null: false
      t.text :error, null: false, default: ""
      t.timestamps
    end

    add_index :deposits, :user_id, unique: false
    add_foreign_key :deposits, :artifacts
    add_foreign_key :deposits, :users
  end
end
