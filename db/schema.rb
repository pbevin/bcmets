# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20120701203222) do

  create_table "albums", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: true do |t|
    t.datetime "sent_at"
    t.datetime "received_at"
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "body"
    t.string   "msgid"
    t.string   "parent_msgid"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
    t.string   "legacy_id"
    t.integer  "user_id"
    t.string   "content_type"
  end

  add_index "articles", ["conversation_id"], name: "index_articles_on_conversation_id", using: :btree
  add_index "articles", ["email"], name: "index_articles_on_email", using: :btree
  add_index "articles", ["msgid"], name: "index_articles_on_msgid", using: :btree
  add_index "articles", ["parent_id"], name: "parent", using: :btree
  add_index "articles", ["parent_msgid"], name: "index_articles_on_parent_msgid", using: :btree
  add_index "articles", ["received_at"], name: "index_articles_on_received_at", using: :btree

  create_table "conversations", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donations", force: true do |t|
    t.string   "email"
    t.date     "date"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_logs", force: true do |t|
    t.string   "email"
    t.string   "reason"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "feed_entries", force: true do |t|
    t.string   "name"
    t.text     "summary"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id"
  end

  create_table "feeds", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "xml_url"
  end

  create_table "holds", force: true do |t|
    t.integer  "subscription_id"
    t.date     "leave"
    t.date     "return"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "text"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "album_id"
    t.binary   "data",        limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_articles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "article_id"
  end

  create_table "subscriptions", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thumbnails", force: true do |t|
    t.binary   "data",       limit: 16777215
    t.integer  "width"
    t.integer  "height"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.boolean  "active"
    t.string   "name"
    t.string   "email_delivery"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "moderated"
  end

end
