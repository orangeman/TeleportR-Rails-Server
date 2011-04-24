# coding: utf-8

require "rubygems"
require "pg"
require "sqlite3"

BUS = 2**0
TRAM = 2**1
UBAHN = 2**2
SBAHN = 2**3
ZUG = 2**4
BOOT = 2**5
STREET = 2**6

osm_db = "osm"
osm_user = "osm"

namespace :import do
  namespace :osm do

	def get_osm_db(dbname)
		db_config = YAML.load_file("#{RAILS_ROOT}/config/database.yml")
		begin
	  	conn = PGconn.connect :dbname => dbname, 
				 										:user => db_config["master"]["username"],
                          	:password => db_config["master"]["password"],
														:host => db_config["master"]["hostname"]
			puts "database #{dbname} exists"
			
    rescue PGError => e  
			starttime = Time.now
			puts "preparing temporary osm database..."
			db_master_user = db_config["master"]["username"]
			db_conn_parameters = "-U #{db_master_user} -h #{db_config["production"]["hostname"]}"
			auth = "PGPASSWORD='#{db_config["master"]["password"]}'"
			cmd = "#{auth} createdb #{db_conn_parameters} #{dbname}"
			%x[#{cmd}]
      puts "temporary database #{dbname} created."

      postgis_path="#{RAILS_ROOT}/db/pg-8.4-postgis-1.5"
      osmosis_path="#{RAILS_ROOT}/db/osmosis-0.35"
      download_path="#{RAILS_ROOT}/tmp/geonames"
#			osmosis_binary="/home/teleportr/osmosis-0.39/bin/osmosis"
      osmosis_binary="/mnt/may-old-root/home/orangeman/osm/osmosis-0.35/bin/osmosis"

	    cmd = "#{auth} createlang #{db_conn_parameters} plpgsql #{dbname}"
			%x[#{cmd}]
			psql = "#{auth} psql #{db_conn_parameters} -d #{dbname} -c client_min_messages=WARNING "
			%x[#{psql} -f #{postgis_path}/postgis.sql]
			%x[#{psql} -f #{postgis_path}/spatial_ref_sys.sql]
#			%x[#{psql} -f /usr/share/postgresql/8.4/contrib/hstore.sql]
			%x[#{psql} -f #{osmosis_path}/pgsql_simple_schema_0.6.sql]
			puts "database gisified."
			state = "bremen" # for test reason
			`wget http://download.geofabrik.de/osm/europe/germany/#{state}.osm.bz2 \
						-O #{download_path}/#{state}.osm.bz2`
			puts "osmosis running..."
  		%x[#{osmosis_binary} \
				    --read-xml #{download_path}/#{state}.osm.bz2 \
    				--write-pgsql database=#{dbname} user=#{db_config["master"]["username"]} password=#{db_config["master"]["password"]}]
			
			conn = PGconn.connect :dbname => dbname, 
				 										:user => db_config["master"]["username"],
                          	:password => db_config["master"]["password"],
														:host => db_config["master"]["hostname"]

			puts "done. (#{(Time.now - starttime )/60000}min)"
		end
		conn	
	end




  desc "going to get all memory away"
  task :test => :environment do
		puts "going to get all memory away"
		puts (get_osm_db "telefoo")
	end  

  desc "download osm data and import to postgis (streets+stations)"
  task :all => [:streets, :stations]

  
  desc "download streets and import to postgis"
  task :streets => :environment do
  
	puts
 # 	state = ENV["state"]
 # 	if not state
 # 		puts "WHICH state should be imported?"
 # 		puts
 # 		break
 # 	end
  	
  conn = get_osm_db("telefoo")
	puts
	
	puts "-- query osm database for streets.."
	query = <<SQL
		SELECT v, way_id
		FROM way_tags 
		WHERE k LIKE '%name%';
SQL
	names = conn.exec query
	puts "   -> Done."
	puts
	
	puts "-- importing streets.."
	
  	state = State.find :first, :conditions => "name iLIKE '%"+"bremen".gsub("ue","ü")+"' AND state_id is null"
  	puts state.name
  	places = []
	p = nil
	names.each do |s|
		query = <<SQL 
				SELECT geom from way_nodes \
				JOIN nodes ON node_id=nodes.id \
				WHERE way_id=#{s["way_id"]}
				LIMIT 1;
SQL
		node = conn.exec query
		p = Place.new :name => s["v"], :latlon => node.first["geom"], :modes => STREET
		places << p
	end
	puts  places.size.to_s + " streets."
	puts "   -> Done."
	puts

	places.uniq!
	puts "(#{places.size.to_s} uniq)"

	puts "-- saving to db.."
	state.places = state.places + places
	Place.transaction do
		state.places.each { |s| s.save}
	end
	puts "   -> Done."
	
	puts
	puts "=================================="
	puts "total: " + places.size.to_s + " streets."
	puts
	
  end
  
  
  
  
  
  
  desc "download public transit stations and import to postgis"
  task :stations => :environment do
  
  	puts
 # 	state = ENV["state"]
 # 	if not state
 # 		puts "WHICH state should be imported?"
 # 		puts
 # 		break
 # 	end
	
	puts
	puts "-- query osm database for stops.."
	query = <<SQL
		SELECT node_id, k, v, geom 
		FROM node_tags JOIN nodes ON nodes.id=node_tags.node_id 
		WHERE node_id IN (
			SELECT node_id 
			FROM node_tags JOIN nodes ON nodes.id=node_tags.node_id
	  		WHERE k='public_transport' AND v='platform'
		   	   OR k='amenity' AND v='bus_station' 
		       OR k='amenity' AND v='station' 
		       OR k='highway' AND v='platform'
		       OR k='highway' AND v='bus_stop' 
		       OR k='railway' AND v='tram_stop'
		       OR k='railway' AND v='platform'
		       OR k='railway' AND v='station'
		       OR k='railway' AND v='halt'
		       OR k='railway' AND v='stop' 
		       OR k='man_made' AND v='pier'
	   	)
		ORDER BY node_id, k='name' DESC
SQL
  
	conn = get_osm_db("telefoo")
	tags = conn.exec query
	puts "   -> Done."

	puts "-- checking modes.."
  	state = State.find :first, :conditions => "name iLIKE '%"+"bremen".gsub("ue","ü")+"' AND state_id is null"
  	puts state.name
  	places = []
	p = Place.new
	tags.each do |t|
		if t["k"] == "name"
			places << p if p.name != nil
			
			p = Place.new :modes => 0
			p.latlon = t["geom"]
			p.name = t['v']
			if p.name =~ /S /
				p.modes |= SBAHN
				p.name.gsub! "S ",""
			end
			if p.name =~ /S-Bhf. /
				p.modes |= SBAHN
				p.name.gsub! "S-Bhf. ",""
			end
			if p.name =~ /U /
				p.modes |= UBAHN
				p.name.gsub! "U ",""
			end
			if p.name =~ /S+U /
				p.modes |= UBAHN
				p.modes |= SBAHN
				p.name.gsub! "S+U ",""
			end
			p.name.gsub!("+", " ").strip!
			#puts "name: "+p.name
		
		
	# relation tags
			relations = conn.exec "SELECT * FROM relation_members JOIN relation_tags 
									ON relation_members.relation_id=relation_tags.relation_id
									WHERE member_id=#{t['node_id']}
									OR member_id IN (SELECT way_id FROM way_nodes 
													  WHERE node_id=#{t['node_id']})"
			relations.each do |rel|
				if rel["k"] == "route"
					if rel["v"] == "bus" || rel["v"] == "Bus"
						p.modes |= BUS
					elsif rel["v"] == "tram"
						p.modes |= TRAM
					elsif rel["v"] == "train"
						p.modes |= ZUG
					elsif rel["v"] == "rail"
						p.modes |= ZUG
					elsif rel["v"] == "ferry"
						p.modes |= BOOT
					elsif rel["v"] == "subway"
						p.modes |= UBAHN
					elsif rel["v"] == "railway"
						p.modes |= SBAHN
					elsif rel["v"] == "railway_track"
						p.modes |= ZUG
					elsif rel["v"] == "light_rail"
						p.modes |= SBAHN
					else # ignore
						puts "     - "+rel["k"]+ " : " + rel["v"] unless (rel["v"] == "road" ||
																		  rel["v"] == "hiking" ||
																		  rel["v"] == "bicycle")
					end
				elsif rel["k"] == "ref"
					if rel["v"] =~ /M\d/ || rel["v"] =~ /Tram/ || rel["v"] =~ /N\d+/
						p.modes |= TRAM
					elsif rel["v"] =~ /S/
						p.modes |= SBAHN
					elsif rel["v"] =~ /U/
						p.modes |= UBAHN
					elsif rel["v"] =~ /R[EB]\s*\d+/ || rel["v"] =~ /IC\s*\d+/
						p.modes |= ZUG
					else # ignore
						puts "     - (rel) "+rel["k"]+ ": " + rel["v"] unless rel["v"] =~ /^\s*\d*\s*$/
					end
				elsif rel["k"] == "line"
					if rel["v"] == "bus"
						p.modes |= BUS
					elsif rel["v"] == "rail"
						p.modes |= ZUG
					elsif rel["v"] == "tram"
						p.modes |= TRAM
					elsif rel["v"] == "light_rail"
                                                p.modes |= SBAHN
					else
						puts "     - (rel) "+rel["k"]+ ": " + rel["v"]
					end
				elsif rel["k"] == "bus_routes"
					p.modes |= BUS
				elsif rel["k"] == "service" && rel["v"] == "busway"
					p.modes |= BUS
				elsif rel["k"] == "type" # ignore
					puts "     - (rel) "+rel["k"]+ ": " + rel["v"] unless (rel["v"] != "site" ||
																	  rel["k"] == "route" ||
																	  rel["k"] == "restriction")
				else # ignore
					puts "     - (rel) "+rel["k"]+ ": " + rel["v"] unless (rel["k"] == "to" ||
																	  rel["k"] == "url" ||
																	  rel["k"] == "from" ||
																	  rel["k"] == "name" ||
																	  rel["k"] == "type" || # !!!
																	  rel["k"] == "note" || # N42 -> Duelferstr
																	  rel["k"] == "site" || # !!!
																	  rel["k"] == "color" ||
																	  rel["v"] == "except" ||
																	  rel["k"] == "network" ||
																	  rel["k"] == "website" ||
																	  rel["k"] == "comment" ||
																	  rel["k"] == "voltage" ||
																	  rel["k"] == "name:en" || # !!!
																	  rel["k"] == "operator" ||
																	  rel["k"] == "alternate" ||
																	  rel["k"] == "frequency" ||
																	  rel["k"] == "addr:city" ||
																	  rel["k"] == "wheelchair" ||
																	  rel["k"] == "restriction" ||
																	  rel["k"] == "electrified"	|| # !!!			
																	  rel["k"] == "website:official")
				end
			end
		
		else
			if t["k"] == "ref"
				if t["v"] =~ /M\d/ || t["v"] =~ /Tram/ || t["v"] =~ /[MN]\d+/
					p.modes |= TRAM
				elsif t["v"] =~ /S/
					p.modes |= SBAHN
				elsif t["v"] =~ /U/
					p.modes |= UBAHN
				elsif t["v"] =~ /R[EB]\s*\d+/ || t["v"] =~ /IC\s*\d+/
					p.modes |= ZUG
				else
					puts "   "+p.name+": " +t["k"]+ " : " + t["v"]
				end
			elsif t["k"] == "highway"
				if t["v"] == "bus_stop"
					p.modes |= BUS
				else
					puts "   "+p.name+": " +t["k"]+ " : " + t["v"]
				end
			elsif t["k"] == "railway"
				if t["v"] == "tram_stop"
					p.modes |= TRAM
				elsif t["v"] == "station"
					#p.modes |= TRAM
				else # ignore
					puts "   "+p.name+": " +t["k"]+ " : " + t["v"] unless (t["v"] == "halt")
				end
			elsif t["k"] == "amenity"
				if t["v"] == "bus_station"
					p.modes |= BUS
				else
					puts "   "+p.name+": " +t["k"]+ " : " + t["v"]
				end
			elsif t["k"] == "station"
				if t["v"] == "subway"
					p.modes |= UBAHN
				elsif t["v"] == "light_rail"
					p.modes |= SBAHN
				else
					puts "   "+p.name+": " +t["k"]+ " : " + t["v"]
				end
			elsif t["k"] == "bus"
				p.modes |= BUS
			elsif t["k"] == "tram"
				p.modes |= TRAM
			elsif t["k"] == "subway"
				p.modes |= UBAHN
			elsif t["k"] == "bus_routes"
				p.modes |= BUS
			elsif t["k"] == "bus_lines"
				p.modes |= BUS
			elsif t["k"] == "tram_routes"
				p.modes |= TRAM
			elsif t["k"] == "tram_lines"
				p.modes |= TRAM
			elsif t["k"] == "rail"
				p.modes |= SBAHN if p.modes == 0
			else # ignore
				puts "   "+p.name+": " +t["k"]+ " : " + t["v"] unless (t["k"] == "bin" ||
															  t["k"] == "bench" ||
															  t["k"] == "layer" ||
															  t["k"] == "source" ||
															  t["k"] == "toilet" ||
															  t["k"] == "shelter" ||
															  t["k"] == "website" ||
															  t["k"] == "network" ||
															  t["k"] == "operator" ||
															  t["k"] == "wheelchair" ||
															  t["k"] == "created_by" ||
															  t["k"] == "surveillance" ||
															  t["k"] == "website:official" || # !!!
															  t["k"] == "public_transport") # !!! ??	
			end
		end	
	end
	places << p
	puts "   -> Done."

	puts
	puts
	puts "=================================="
	puts "total: " + places.size.to_s + " stops."

	puts
	puts "-- saving to db.."
	state.places = state.places + places
	Place.transaction do 
		places.each { |s| s.save} 
	end
	puts "   -> Done."
	
  end
end
end

