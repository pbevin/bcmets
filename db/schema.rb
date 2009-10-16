# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091015202720) do

  create_table "albums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :force => true do |t|
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
  end

  add_index "articles", ["conversation_id"], :name => "index_articles_on_conversation_id"
  add_index "articles", ["email"], :name => "index_articles_on_email"
  add_index "articles", ["msgid"], :name => "index_articles_on_msgid"
  add_index "articles", ["parent_msgid"], :name => "index_articles_on_parent_msgid"
  add_index "articles", ["received_at"], :name => "index_articles_on_received_at"

  create_table "conversations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donations", :force => true do |t|
    t.string   "email"
    t.date     "date"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holds", :force => true do |t|
    t.integer  "subscription_id"
    t.date     "leave"
    t.date     "return"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "album_id"
    t.binary   "data",        :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thumbnails", :force => true do |t|
    t.binary   "data",       :limit => 16777215
    t.integer  "width"
    t.integer  "height"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "email_delivery"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
