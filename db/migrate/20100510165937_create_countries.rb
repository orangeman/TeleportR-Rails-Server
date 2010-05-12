class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries, :id => false do |t|
      t.string :iso, :primary => true
      t.string :tld
      t.string :name
      t.integer :area
      t.string :capital
      t.string :currency
      t.string :continent
      t.integer :population
      t.string :currency_code

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
