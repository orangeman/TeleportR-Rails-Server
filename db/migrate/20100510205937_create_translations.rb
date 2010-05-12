class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations, :id => false do |t|
      t.integer :id, :primary => true
      t.string :iso
      t.string :name
      t.references :geoname
      t.boolean :isShortName
      t.boolean :isPreferredName

      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
