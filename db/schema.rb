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

ActiveRecord::Schema.define(:version => 20130118123454) do

  create_table "pages", :force => true do |t|
    t.integer  "site_id",                                            :null => false
    t.integer  "template_id",                                        :null => false
    t.string   "page_name",   :limit => 128, :default => "Untitled", :null => false
    t.string   "language",    :limit => 2
    t.integer  "theme_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "sites", :force => true do |t|
    t.integer  "vendor_id",                                                                            :null => false
    t.integer  "landing_page_id"
    t.string   "site_name",       :limit => 128,                               :default => "Untitled", :null => false
    t.string   "site_type",       :limit => 128
    t.decimal  "latitude",                       :precision => 9, :scale => 6, :default => 35.692984,  :null => false
    t.decimal  "longitude",                      :precision => 9, :scale => 6, :default => 139.754232, :null => false
    t.string   "logo",            :limit => 256
    t.text     "description"
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.string   "address"
    t.string   "telephone"
  end

  create_table "templates", :force => true do |t|
    t.string   "file_path",   :limit => 256, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "vendor_id"
    t.string   "description"
  end

  create_table "themes", :force => true do |t|
    t.string   "bg_color",          :limit => 7, :null => false
    t.string   "main_text_color",   :limit => 7, :null => false
    t.string   "normal_text_color", :limit => 7, :null => false
    t.string   "button_color",      :limit => 7, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "uploads", :force => true do |t|
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "vendor_id"
    t.integer  "site_id"
    t.string   "desc"
  end

  create_table "vendors", :force => true do |t|
    t.string   "vendor_name"
    t.string   "username"
    t.string   "crypted_password"
    t.string   "contact_person"
    t.string   "address"
    t.string   "email"
    t.string   "telephone"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "logo",                            :limit => 256
    t.string   "salt"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer  "failed_logins_count",                            :default => 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
  end

  add_index "vendors", ["activation_token"], :name => "index_vendors_on_activation_token"
  add_index "vendors", ["reset_password_token"], :name => "index_vendors_on_reset_password_token"

end
