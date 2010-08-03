class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.string :title
      t.string :url
      t.references :area

      t.timestamps
    end
  end

  def self.down
    drop_table :plugins
  end
end
