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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130421205015) do

  create_table "auths", :force => true do |t|
    t.string   "uid"
    t.string   "token"
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "encrypted_secret"
    t.string   "encrypted_secret_salt"
    t.string   "encrypted_secret_iv"
    t.integer  "provider_id"
  end

  add_index "auths", ["site_id"], :name => "index_auths_on_site_id"
  add_index "auths", ["uid"], :name => "index_auths_on_uid"
  add_index "auths", ["user_id"], :name => "index_auths_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "exports", :force => true do |t|
    t.string   "method"
    t.text     "filter"
    t.integer  "auth_id"
    t.boolean  "is_exported"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.text     "description"
    t.boolean  "is_exporting"
    t.string   "format"
    t.integer  "total"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "pages"
    t.string   "type",              :default => "Export"
    t.string   "source"
    t.string   "target"
    t.boolean  "articles"
    t.boolean  "cases"
    t.boolean  "interactions"
    t.boolean  "customers"
    t.boolean  "topics"
    t.integer  "from_id"
  end

  add_index "exports", ["auth_id"], :name => "index_exports_on_auth_id"
  add_index "exports", ["from_id"], :name => "index_exports_on_from_id"

  create_table "imports", :force => true do |t|
    t.string   "method"
    t.string   "format"
    t.text     "description"
    t.boolean  "is_imported"
    t.boolean  "is_importing"
    t.integer  "auth_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "logfile_file_name"
    t.string   "logfile_content_type"
    t.integer  "logfile_file_size"
    t.datetime "logfile_updated_at"
    t.string   "type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "imports", ["auth_id"], :name => "index_imports_on_auth_id"

  create_table "providers", :force => true do |t|
    t.string "type"
    t.string "name"
  end

  add_index "providers", ["name"], :name => "index_providers_on_name", :unique => true
  add_index "providers", ["type"], :name => "index_providers_on_type", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sites", ["name"], :name => "index_sites_on_name"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email"

end
