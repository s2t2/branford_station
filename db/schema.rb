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

ActiveRecord::Schema.define(version: 20150131052943) do

  create_table "data_exchange_agencies", force: :cascade do |t|
    t.string   "dataexchange_id",   limit: 255, null: false
    t.string   "name",              limit: 255
    t.string   "url",               limit: 255
    t.string   "dataexchange_url",  limit: 255
    t.string   "feed_baseurl",      limit: 255
    t.string   "license_url",       limit: 255
    t.string   "country",           limit: 255
    t.string   "state",             limit: 255
    t.string   "area",              limit: 255
    t.boolean  "is_official",       limit: 1
    t.datetime "date_added"
    t.datetime "date_last_updated"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "data_exchange_agencies", ["dataexchange_id"], name: "index_data_exchange_agencies_on_dataexchange_id", unique: true, using: :btree

  create_table "google_transit_data_feed_public_feed_agencies", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.string   "name",       limit: 255
    t.string   "area",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "google_transit_data_feed_public_feeds", force: :cascade do |t|
    t.integer  "agency_id",  limit: 4
    t.string   "url",        limit: 255
    t.string   "name",       limit: 255
    t.text     "notes",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "google_transit_data_feed_public_feeds", ["agency_id"], name: "index_google_transit_data_feed_public_feeds_on_agency_id", using: :btree

end