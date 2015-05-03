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

ActiveRecord::Schema.define(version: 20150502232527) do

  create_table "agency_versions", force: :cascade do |t|
    t.integer  "version_id", limit: 4,   null: false
    t.string   "identifier", limit: 255
    t.string   "name",       limit: 255, null: false
    t.string   "url",        limit: 255, null: false
    t.string   "timezone",   limit: 255, null: false
    t.string   "lang",       limit: 255
    t.string   "phone",      limit: 255
    t.string   "fare_url",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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

  create_table "feed_hosts", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "feed_hosts", ["name"], name: "index_feed_hosts_on_name", unique: true, using: :btree

  create_table "feed_versions", force: :cascade do |t|
    t.integer  "feed_id",          limit: 4,     null: false
    t.datetime "last_modified_at",               null: false
    t.text     "etag",             limit: 65535
    t.integer  "response_code",    limit: 4
    t.string   "response_message", limit: 255
    t.text     "accept_ranges",    limit: 65535
    t.text     "cache_control",    limit: 65535
    t.text     "connection",       limit: 65535
    t.text     "content_type",     limit: 65535
    t.text     "content_language", limit: 65535
    t.text     "content_length",   limit: 65535
    t.datetime "expires"
    t.text     "server",           limit: 65535
    t.text     "x_powered_by",     limit: 65535
    t.text     "set_cookie",       limit: 65535
    t.datetime "last_checked_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "feed_versions", ["feed_id"], name: "index_feed_versions_on_feed_id", using: :btree
  add_index "feed_versions", ["last_checked_at"], name: "index_feed_versions_on_last_checked_at", using: :btree
  add_index "feed_versions", ["last_modified_at"], name: "index_feed_versions_on_last_modified_at", using: :btree

  create_table "feeds", force: :cascade do |t|
    t.integer  "host_id",    limit: 4,   null: false
    t.string   "source_url", limit: 255, null: false
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "feeds", ["host_id"], name: "index_feeds_on_host_id", using: :btree
  add_index "feeds", ["source_url"], name: "index_feeds_on_source_url", unique: true, using: :btree

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

  create_table "route_versions", force: :cascade do |t|
    t.integer  "version_id",        limit: 4,   null: false
    t.string   "identifier",        limit: 255, null: false
    t.string   "agency_identifier", limit: 255
    t.string   "short_name",        limit: 255, null: false
    t.string   "long_name",         limit: 255, null: false
    t.string   "description",       limit: 255
    t.integer  "route_type",        limit: 4,   null: false
    t.string   "url",               limit: 255
    t.string   "color",             limit: 255
    t.string   "text_color",        limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "route_versions", ["agency_identifier"], name: "index_route_versions_on_agency_identifier", using: :btree
  add_index "route_versions", ["identifier"], name: "index_route_versions_on_identifier", using: :btree
  add_index "route_versions", ["version_id"], name: "index_route_versions_on_version_id", using: :btree

  create_table "stop_time_versions", force: :cascade do |t|
    t.integer  "version_id",          limit: 4,   null: false
    t.string   "trip_identifier",     limit: 255, null: false
    t.string   "arrival_time",        limit: 255, null: false
    t.string   "departure_time",      limit: 255, null: false
    t.string   "stop_identifier",     limit: 255, null: false
    t.integer  "stop_sequence",       limit: 4,   null: false
    t.string   "stop_headsign",       limit: 255
    t.integer  "pickup_type",         limit: 4
    t.integer  "drop_off_type",       limit: 4
    t.string   "shape_dist_traveled", limit: 255
    t.integer  "timepoint",           limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "stop_time_versions", ["stop_identifier"], name: "index_stop_time_versions_on_stop_identifier", using: :btree
  add_index "stop_time_versions", ["trip_identifier"], name: "index_stop_time_versions_on_trip_identifier", using: :btree
  add_index "stop_time_versions", ["version_id"], name: "index_stop_time_versions_on_version_id", using: :btree

  create_table "stop_versions", force: :cascade do |t|
    t.integer  "version_id",          limit: 4,                            null: false
    t.string   "identifier",          limit: 255,                          null: false
    t.string   "code",                limit: 255
    t.string   "name",                limit: 255,                          null: false
    t.string   "description",         limit: 255
    t.decimal  "latitude",                        precision: 10, scale: 8, null: false
    t.decimal  "longitude",                       precision: 11, scale: 8, null: false
    t.string   "zone_identifier",     limit: 255
    t.string   "url",                 limit: 255
    t.string   "location_type",       limit: 255
    t.string   "parent_station",      limit: 255
    t.string   "timezone",            limit: 255
    t.string   "wheelchair_boarding", limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "trip_versions", force: :cascade do |t|
    t.integer  "version_id",            limit: 4,   null: false
    t.string   "route_identifier",      limit: 255, null: false
    t.string   "service_identifier",    limit: 255, null: false
    t.string   "identifier",            limit: 255, null: false
    t.string   "headsign",              limit: 255
    t.string   "short_name",            limit: 255
    t.integer  "direction_identifier",  limit: 4
    t.string   "block_identifier",      limit: 255
    t.string   "shape_identifier",      limit: 255
    t.integer  "wheelchair_accessible", limit: 4
    t.integer  "bikes_allowed",         limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "trip_versions", ["block_identifier"], name: "index_trip_versions_on_block_identifier", using: :btree
  add_index "trip_versions", ["identifier"], name: "index_trip_versions_on_identifier", using: :btree
  add_index "trip_versions", ["route_identifier"], name: "index_trip_versions_on_route_identifier", using: :btree
  add_index "trip_versions", ["service_identifier"], name: "index_trip_versions_on_service_identifier", using: :btree
  add_index "trip_versions", ["shape_identifier"], name: "index_trip_versions_on_shape_identifier", using: :btree
  add_index "trip_versions", ["version_id"], name: "index_trip_versions_on_version_id", using: :btree

end
