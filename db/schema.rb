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

ActiveRecord::Schema[7.1].define(version: 2024_02_15_180653) do
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
    t.index ["name"], name: "index_administrators_on_name", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id", "question_id"], name: "index_answers_on_user_id_and_question_id", unique: true
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "github_uid"
    t.string "github_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "user_id"
    t.index ["github_uid"], name: "index_authors_on_github_uid", unique: true
    t.index ["github_username"], name: "index_authors_on_github_username", unique: true
    t.index ["user_id"], name: "index_authors_on_user_id", unique: true
  end

  create_table "builds", force: :cascade do |t|
    t.bigint "repository_id"
    t.datetime "completed_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.string "aasm_state"
    t.index ["repository_id"], name: "index_builds_on_repository_id"
  end

  create_table "github_installations", force: :cascade do |t|
    t.bigint "author_id"
    t.string "uid"
    t.string "username"
    t.string "installation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_github_installations_on_author_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "answer_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_likes_on_answer_id"
    t.index ["user_id", "answer_id"], name: "index_likes_on_user_id_and_answer_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "build_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "failure", default: false
    t.index ["build_id"], name: "index_logs_on_build_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "repository_id"
    t.string "tag"
    t.string "page_path"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.uuid "batch_code"
    t.index ["repository_id"], name: "index_questions_on_repository_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "name"
    t.string "branch"
    t.string "description"
    t.datetime "last_pull_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.boolean "banned", default: false
    t.bigint "github_installation_id"
    t.bigint "uid"
    t.index ["github_installation_id"], name: "index_repositories_on_github_installation_id"
    t.index ["name", "github_installation_id"], name: "index_repositories_on_name_and_github_installation_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
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

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "authors", "users"
  add_foreign_key "builds", "repositories"
  add_foreign_key "github_installations", "authors"
  add_foreign_key "likes", "answers"
  add_foreign_key "likes", "users"
  add_foreign_key "logs", "builds"
  add_foreign_key "questions", "repositories"
  add_foreign_key "repositories", "github_installations"
  add_foreign_key "webauthn_credentials", "administrators"
end
