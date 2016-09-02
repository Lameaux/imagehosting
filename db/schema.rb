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

  create_table "albums", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",          limit: 36,                                         null: false
    t.string   "title"
    t.text     "description", limit: 65535
    t.string   "user_id",     limit: 36,                                         null: false
    t.integer  "hidden",                    default: 0
    t.integer  "views",                     default: 0
    t.integer  "likes",                     default: 0
    t.datetime "created_at",                default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["created_at"], name: "albums_created_at", using: :btree
    t.index ["id"], name: "albums_id", using: :btree
    t.index ["user_id"], name: "albums_user_id", using: :btree
  end

  create_table "images", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",          limit: 36,                                         null: false
    t.string   "title"
    t.string   "tags"
    t.text     "description", limit: 65535
    t.string   "file_ext",    limit: 3
    t.integer  "file_size"
    t.integer  "width"
    t.integer  "height"
    t.string   "user_id",     limit: 36,                                         null: false
    t.string   "album_id",    limit: 36,                                         null: false
    t.integer  "album_index",               default: 0
    t.integer  "hidden",                    default: 0
    t.integer  "views",                     default: 0
    t.integer  "likes",                     default: 0
    t.datetime "created_at",                default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["album_id"], name: "images_album_id", using: :btree
    t.index ["album_index"], name: "images_album_index", using: :btree
    t.index ["created_at"], name: "images_created_at", using: :btree
    t.index ["file_ext"], name: "images_file_ext", using: :btree
    t.index ["id"], name: "images_id", using: :btree
    t.index ["user_id"], name: "images_user_id", using: :btree
    t.index ["views"], name: "images_views", using: :btree
    t.index ["width"], name: "images_width", using: :btree
  end

  create_table "users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "id",              limit: 36,                                      null: false
    t.string   "username",                                                        null: false
    t.string   "email",                                                           null: false
    t.string   "password_digest"
    t.string   "activation_code", limit: 36
    t.string   "reset_code",      limit: 36
    t.integer  "active",                     default: 0
    t.datetime "created_at",                 default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                                                      null: false
    t.index ["email"], name: "users_email", unique: true, using: :btree
    t.index ["id"], name: "users_id", using: :btree
    t.index ["username"], name: "users_username", unique: true, using: :btree
  end

end
