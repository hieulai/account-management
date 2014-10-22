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

ActiveRecord::Schema.define(version: 20141020162606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company_name"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "phone_tag_1"
    t.string   "phone_tag_2"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "website"
    t.integer  "user_id"
  end

  create_table "people", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "phone_tag_1"
    t.string   "phone_tag_2"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "website"
    t.integer  "user_id"
  end

  create_table "relationships", force: true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.string   "association_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reflex"
  end

  add_index "relationships", ["contact_id"], name: "index_relationships_on_contact_id", using: :btree
  add_index "relationships", ["user_id"], name: "index_relationships_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.boolean  "active"
    t.integer  "profile_id"
    t.string   "profile_type"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

end
