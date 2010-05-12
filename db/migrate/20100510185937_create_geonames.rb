class CreateGeonames < ActiveRecord::Migration
  def self.up
    create_table :geonames, :id => false do |t|
      t.integer :id, :primary => true
      t.string :name
      t.string :type
      t.string :timezone
      t.references :state
      t.string :country_iso
      t.integer :population

      t.timestamps
    end
    execute "SELECT AddGeometryColumn('geonames', 'latlon', 4326, 'POINT', 2);"
    execute "CREATE INDEX idx_geonames_latlon ON geonames USING gist (latlon);"
  end

  def self.down
    drop_table :geonames
  end
end
