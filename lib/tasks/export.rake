#coding: utf-8

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

$icon_BOOT = 0x7f020000
$icon_BUS = 0x7f020001
$icon_SBAHN = 0x7f020002
$icon_STREET = 0x7f020003
$icon_TRAM = 0x7f020004
$icon_UBAHN = 0x7f020005
$icon_ZUG = 0x7f020006

namespace :export do

  desc "download osm data and import to postgis (streets+stations)"
  task :all => [:stations, :streets]
  
  desc "generate one download with stations file for each state"
  task :stations => :environment do
  	
  	puts
  	Download.delete_all "title like 'Haltestellen_%'"
  	
  	states = State.find :all, :conditions => "state_id is null"
  	
  	states.each do |s|
  	
  		stations = Place.find_by_sql "SELECT name, modes, ST_AsText(latlon) AS latlon
    							 		FROM places 
    							 		WHERE state_id=#{s.id} AND modes!=64
    							 		ORDER BY name;"
 		next if stations.size == 0
  		stations.uniq!
 		
  		d = Download.new
  		d.title = "Haltestellen "+s.name.split(" ").last
		d.file = d.title.gsub(" ", "_")+".db"
		d.size = stations.size
		d.latlon = s.latlon
		d.radius = 300

		puts " -- generating "+d.title+"  ("+d.size.to_s+") ..."
  		createSqliteFile d.file, stations
		d.save
  		puts "    --> Done."
  		puts
		
  	end
  end

  desc "generate one download with streets for each city"
  task :streets => :environment do
  	
  	puts
  	Download.delete_all "title like 'Straßen_%'"
  	
  	cities = City.find :all, :conditions => "population > 0", 
  							 :order => "population DESC",
  							 :limit => 2342
  	
  	puts
  	puts "found "+cities.size.to_s+" cities"
  	cities.uniq!
  	puts "uniq: "+cities.size.to_s
  	puts
  	
  	cities.each_with_index do |c, i|
  		
  		streets = Place.find_by_sql "SELECT name, modes, ST_AsText(latlon) AS latlon
    							 	 FROM places 
    							 	 WHERE ST_DWithin('#{c.latlon}', latlon, 0.7)
    							 	 AND modes=#{STREET}
    							 	 ORDER BY name;"
 		next if streets.size == 0
 		
 		# separation
 		neighbours = Download.find_by_sql "SELECT * FROM downloads
 							  			   WHERE ST_DWithin('#{c.latlon}', latlon, 0.3)
 							  			   AND title like 'Straßen_%';"
  		if neighbours.size > 0
  			puts c.name+" is too close to already existent street downloads"
  			next
		end
 		
 		streets.uniq! # Berlin/Brandenburg!
 		
  		d = Download.new
  		d.title = "Straßen "+c.name
		d.file = d.title.gsub(" ", "_")+".db"
		d.size = streets.size
		d.latlon = c.latlon
		d.radius = 70
		
  		puts " -- generating "+d.title+"  ("+d.size.to_s+") ..."
  		createSqliteFile d.file, streets
		d.save
  		puts "    --> Done."
		puts
  	end
  end 
end
 

  def createSqliteFile(file, places)
    `rm #{"public/downloads/"+file}`
		db = SQLite3::Database.new( "public/downloads/"+file )
		db.execute "CREATE TABLE android_metadata (locale TEXT)"
		db.execute "INSERT INTO android_metadata VALUES ('en_US')"
		db.execute "CREATE TABLE places (_id INTEGER PRIMARY KEY,
		               					 name TEXT COLLATE NOCASE,
		               					 icon INTEGER,
		               					 lat INTEGER,
		               					 lon INTEGER);"
		places.each do |p|
		   	if p.modes & STREET != 0
		   		p.modes = $icon_STREET
		   	elsif p.modes & ZUG != 0
		   		p.modes = $icon_ZUG
		   	elsif p.modes & SBAHN != 0
		   		p.modes = $icon_SBAHN
		   	elsif p.modes & UBAHN != 0
		   		p.modes = $icon_UBAHN
		   	elsif p.modes & BOOT != 0
		   		p.modes = $icon_BOOT
		   	elsif p.modes & TRAM != 0
		   		p.modes = $icon_TRAM
		   	elsif p.modes & BUS != 0
		   		p.modes = $icon_BUS
		   	else
		   		#puts p.name+" has no type :("
		   	end
		end
		
		places.uniq!
		   	
		places.each_with_index do |p, i|
			if p.name =~ /^\s*[\d,-]*\s*$/ || p.name.size < 3
		      #puts "  - weggelassen #{p.name}"
		      next
		   	end
		   	latlon = p.latlon.match /\((\d+\.\d+) (\d+\.\d+)/
		   	if latlon
			  lat = (latlon[2].to_f * 1E6).to_i
			  lon = (latlon[1].to_f * 1E6).to_i
			else
			  lat = 0
			  lon = 0
			end
		   	db.execute "INSERT INTO places (_id, name, icon, lat, lon) 
		                VALUES (?,?,?,?,?)", i+1 , p.name, p.modes, lat, lon
		   	#puts "  + inserted #{p.name}"
		  end 
  end

	

