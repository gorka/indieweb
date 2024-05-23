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

ActiveRecord::Schema[7.1].define(version: 2024_05_22_232428) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blogs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "subdomain", null: false
    t.string "authorization_endpoint"
    t.string "token_endpoint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_domain"
    t.string "password_digest"
    t.index ["subdomain"], name: "index_blogs_on_subdomain", unique: true
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "categorizable_type", null: false
    t.bigint "categorizable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categorizable_type", "categorizable_id"], name: "index_categorizations_on_categorizable"
    t.index ["category_id", "categorizable_type", "categorizable_id"], name: "unique_category_categorizable", unique: true
    t.index ["category_id"], name: "index_categorizations_on_category_id"
  end

  create_table "entries", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "blog_id", null: false
    t.datetime "deleted_at"
    t.string "name"
    t.string "status", default: "published"
    t.text "html_content"
    t.index ["blog_id"], name: "index_entries_on_blog_id"
  end

  create_table "microformat_photos", force: :cascade do |t|
    t.bigint "photo_with_alt_id", null: false
    t.string "photoable_type", null: false
    t.bigint "photoable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["photo_with_alt_id"], name: "index_microformat_photos_on_photo_with_alt_id"
    t.index ["photoable_type", "photoable_id"], name: "index_microformat_photos_on_photoable"
  end

  create_table "omniauth_providers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_omniauth_providers_on_user_id"
  end

  create_table "photos_with_alt", force: :cascade do |t|
    t.string "alt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blogs", "users"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "entries", "blogs"
  add_foreign_key "microformat_photos", "photos_with_alt", column: "photo_with_alt_id"
  add_foreign_key "omniauth_providers", "users"
end
