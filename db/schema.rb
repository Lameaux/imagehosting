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

ActiveRecord::Schema.define(version: 3) do

  create_table "collections", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",         limit: 36,                                      null: false
    t.string   "title"
    t.string   "user_id",    limit: 36
    t.datetime "created_at",            default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                 null: false
    t.index ["id"], name: "collections_id", using: :btree
  end

  create_table "images", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",            limit: 36,                                      null: false
    t.string   "title"
    t.string   "file_ext"
    t.integer  "file_size"
    t.string   "user_id",       limit: 36
    t.string   "collection_id", limit: 36
    t.datetime "created_at",               default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                    null: false
    t.index ["collection_id"], name: "images_collection_id", using: :btree
    t.index ["created_at"], name: "images_created_at", using: :btree
    t.index ["id"], name: "images_id", using: :btree
    t.index ["user_id"], name: "images_user_id", using: :btree
  end

  create_table "users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",         limit: 36,                                      null: false
    t.string   "email",                                                      null: false
    t.string   "password",                                                   null: false
    t.integer  "active",                default: 0,                          null: false
    t.datetime "created_at",            default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                 null: false
    t.index ["email"], name: "users_email", unique: true, using: :btree
    t.index ["id"], name: "users_id", using: :btree
  end

end
