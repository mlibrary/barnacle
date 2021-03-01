# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :revisions do |t|
      t.string :artifact_id, null: false, index: false
      t.belongs_to :deposit, null: false, index: false
      t.timestamps
    end

    add_index :revisions, :artifact_id, unique: false
    add_index :revisions, :deposit_id, unique: true
    add_foreign_key :revisions, :artifacts
    add_foreign_key :revisions, :deposits
  end
end
