class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.string :name

      t.timestamps
    end
    
    create_table :downloads_places do |t|
      t.references :download
      t.references :place

      t.timestamps
    end
  end

  def self.down
    drop_table :downloads
    drop_table :downloads_places
  end
end
