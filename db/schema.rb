# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190813153819) do

# Could not dump table "artifacts" because of following StandardError
#   Unknown type 'uuid' for column 'id'

  create_table "audits", force: :cascade do |t|
    t.integer "user_id"
    t.integer "packages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "deposits", force: :cascade do |t|
    t.string "artifact_id", null: false
    t.integer "user_id", null: false
    t.string "status", null: false
    t.text "error", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_deposits_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "package_id"
    t.string "event_type"
    t.integer "user_id"
    t.string "outcome"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "audit_id"
    t.index ["audit_id"], name: "index_events_on_audit_id"
    t.index ["package_id"], name: "index_events_on_package_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "bag_id", null: false
    t.integer "user_id", null: false
    t.string "external_id", null: false
    t.string "storage_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_type", default: "default", null: false
    t.string "format", default: "bag", null: false
    t.string "storage_volume"
    t.index ["bag_id"], name: "index_packages_on_bag_id", unique: true
    t.index ["external_id"], name: "index_packages_on_external_id", unique: true
    t.index ["user_id"], name: "index_packages_on_user_id"
  end

  create_table "queue_items", force: :cascade do |t|
    t.integer "package_id"
    t.integer "status", default: 0, null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["package_id"], name: "index_queue_items_on_package_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.string "artifact_id", null: false
    t.integer "deposit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artifact_id"], name: "index_revisions_on_artifact_id"
    t.index ["deposit_id"], name: "index_revisions_on_deposit_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
