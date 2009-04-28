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

ActiveRecord::Schema.define(:version => 20090427153638) do

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
  end

  add_index "articles", ["email"], :name => "index_articles_on_email"
  add_index "articles", ["msgid"], :name => "index_articles_on_msgid"
  add_index "articles", ["parent_msgid"], :name => "index_articles_on_parent_msgid"
  add_index "articles", ["received_at"], :name => "index_articles_on_received_at"

  create_table "donations", :force => true do |t|
    t.string   "email"
    t.date     "date"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
