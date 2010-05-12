class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :name
      t.string :type
      t.integer :modes
      t.references :city
      t.references :state
      t.string :country_iso

      t.timestamps
    end
    execute "SELECT AddGeometryColumn('places', 'latlon', 4326, 'POINT', 2);"
    execute "CREATE INDEX idx_places_geom ON places USING gist (latlon);"
  end

  def self.down
    drop_table :places
  end
end
