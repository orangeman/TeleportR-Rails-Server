class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.string :title
      t.string :file
      t.integer :radius
      t.integer :size

      t.timestamps
    end
    execute "SELECT AddGeometryColumn('downloads', 'latlon', 4326, 'POINT', 2);"
    execute "CREATE INDEX idx_downloads_geom ON downloads USING gist (latlon);"
    
  end

  def self.down
    drop_table :downloads
  end
end
