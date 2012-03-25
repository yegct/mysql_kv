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

ActiveRecord::Schema.define(:version => 20120323142608) do

  create_table "key_indices", :force => true do |t|
    t.string   "key",                      :null => false
    t.binary   "key_hash",   :limit => 16, :null => false
    t.integer  "data_type",  :limit => 1,  :null => false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "key_indices", ["expires_at"], :name => "index_key_indices_on_expires_at"
  add_index "key_indices", ["key"], :name => "index_key_indices_on_key", :unique => true
  add_index "key_indices", ["key_hash"], :name => "index_key_indices_on_key_hash"

  create_table "key_value_integers", :primary_key => "key_index_id", :force => true do |t|
    t.integer "value", :limit => 8, :null => false
  end

  create_table "key_value_long_strings", :primary_key => "key_index_id", :force => true do |t|
    t.text "value", :limit => 2147483647, :null => false
  end

  create_table "key_value_strings", :primary_key => "key_index_id", :force => true do |t|
    t.string "value", :null => false
  end

end
