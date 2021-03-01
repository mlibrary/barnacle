# frozen_string_literal: true

class CreateArtifacts < ActiveRecord::Migration[5.1]
  def change
    create_table :artifacts, id: :uuid do |t|
      t.string :content_type, null: false
      t.string :storage_volume, null: true
      t.string :storage_format, null: false
      t.references :user, null: false, index: false
      t.timestamps
    end

    add_index :artifacts, :user_id, unique: false
    add_foreign_key :artifacts, :users
  end
end
