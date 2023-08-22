# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_22_180842) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "administrators", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.string "permissions", default: "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "github_uid"
    t.string "github_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.string "git_url"
    t.string "branch"
    t.string "description"
    t.datetime "last_pull_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.bigint "author_id"
    t.string "title"
    t.boolean "hidden", default: false
    t.index ["author_id"], name: "index_repositories_on_author_id"
  end

  create_table "webauthn_credentials", force: :cascade do |t|
    t.bigint "administrator_id"
    t.string "external_id"
    t.string "public_key"
    t.string "nickname"
    t.bigint "sign_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_webauthn_credentials_on_administrator_id"
    t.index ["external_id"], name: "index_webauthn_credentials_on_external_id", unique: true
  end

  add_foreign_key "repositories", "authors"
  add_foreign_key "webauthn_credentials", "administrators"
end
