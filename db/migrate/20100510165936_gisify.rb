class Gisify < ActiveRecord::Migration
  def self.up
	puts "start plpgsql creation"
	# inasty hack using the master db settings to gisify database
	db = YAML.load_file("#{RAILS_ROOT}/config/database.yml")
	db_master_user = db["master"]["username"]
	
	auth = "PGPASSWORD='#{db["master"]["password"]}'"
	master_db = db["master"]["database"]
	prod_db = db["production"]["database"]
	
	postgis_database_path="#{RAILS_ROOT}/db/pg-8.4-postgis-1.5"
	osmosis_database_path="#{RAILS_ROOT}/db/osmosis-0.35"
	db_conn_parameters = "-U #{db_master_user} -h #{db["production"]["hostname"]}"
	psql = "#{auth} psql #{db_conn_parameters} -d #{prod_db}"

        `#{auth} createlang #{db_conn_parameters} plpgsql #{db["production"]["database"]}`
	puts "plpgsql created"
	`#{psql} -f #{postgis_database_path}/postgis.sql`
	puts "postgis.sql injected"
	`#{psql} -f #{postgis_database_path}/spatial_ref_sys.sql`
	puts "spatial_ref_sys.sql injected"
	ownerfix = "ALTER TABLE spatial_ref_sys OWNER TO teleportr;"
	ownerfix += "ALTER TABLE geometry_columns OWNER TO teleportr;"
	ownerfix += "ALTER TABLE geography_columns OWNER TO teleportr;"
	%x[echo "#{ownerfix}" | #{psql}]
	puts "owner fickst"
  end

  def self.down
    drop_table :countries
  end
end
