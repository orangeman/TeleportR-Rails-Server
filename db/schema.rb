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

ActiveRecord::Schema.define(:version => 20100510230615) do

  create_table "countries", :id => false, :force => true do |t|
    t.string   "iso"
    t.string   "tld"
    t.string   "name"
    t.integer  "area"
    t.string   "capital"
    t.string   "currency"
    t.string   "continent"
    t.integer  "population"
    t.string   "currency_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downloads", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downloads_places", :force => true do |t|
    t.integer  "download_id"
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geometry_columns", :id => false, :force => true do |t|
    t.string  "f_table_catalog",   :limit => 256, :null => false
    t.string  "f_table_schema",    :limit => 256, :null => false
    t.string  "f_table_name",      :limit => 256, :null => false
    t.string  "f_geometry_column", :limit => 256, :null => false
    t.integer "coord_dimension",                  :null => false
    t.integer "srid",                             :null => false
    t.string  "type",              :limit => 30,  :null => false
  end

# Could not dump table "geonames" because of following StandardError
#   Unknown type 'geometry' for column 'latlon'

# Could not dump table "places" because of following StandardError
#   Unknown type 'geometry' for column 'latlon'

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "translations", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.integer  "geoname_id"
    t.boolean  "isPreferredName"
    t.boolean  "isShortName"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
