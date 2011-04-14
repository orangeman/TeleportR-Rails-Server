require "rubygems"
require "pg"
require "sqlite3"

temppath = "#{RAILS_ROOT}/tmp/geonames"

namespace :import do
  
  desc "download and import states/cities of one country"
  task :geonames => :environment do
        # warning nach dem naechsten deploy ist alles wecj	
	`mkdir #{temppath}`
  	puts
  	country = ENV["country"]
  	if not country
  		puts "WHICH country should be imported?"
  		puts
  		break
  	end
	
		`rm #{temppath}/#{country}.txt`
		`rm #{temppath}/readme.txt`
		`wget http://download.geonames.org/export/dump/#{country}.zip \
							-O #{temppath}/#{country}.zip`
		`unzip -d #{temppath} #{temppath}/#{country}.zip`
		
		puts "-- reading states / cities.. "
		geonames = []
		File.open("#{temppath}/#{country}.txt", "r").each do |line|
			unless line.start_with? "#"
			  	g = line.split "\t"
			  	
			  	if g[7] == "ADM1" || g[7] == "ADM2"
			  		n = State.new
			  	elsif g[7] =~ /PPL.*/  # populated place
			  		n = City.new
			  	else
			  		next
			  	end
		  		n.id = g[0]
		  		n.name = g[1]
		  		n.state_id = g[10]
		  		n.timezone = g[17]
		  		n.population = g[14]
		  		n.country_iso = country
			  	n.latlon = Place.find_by_sql("SELECT ST_GeomFromText(
			  			   'POINT(#{g[5]} #{g[4]})', 4326)")[0].st_geomfromtext
			  	geonames << n
		  	end
		end
		puts "   -> Done."
		puts
		
		puts "-- saving.. "
		Geoname.transaction do
			geonames.each { |g| g.save }
		end
		puts "   -> Done."
		puts
		
		puts "-- associating states.. "
		lookUpState = {}
		`rm #{temppath}/admin1Codes.txt`
		`wget http://download.geonames.org/export/dump/admin1Codes.txt \
							-O #{temppath}/admin1Codes.txt`
		File.open("#{temppath}/admin1Codes.txt", "r").each do |line|
			s = line.split "\t"
			if s[0].start_with? country
				translations = (Translation.find :all, :conditions => {:name => s[1].strip}
						  			).select { |t| t.geoname && t.geoname.type == "State" }
				if translations.size > 0
					lookUpState[s[0].split(".")[1].to_i] = translations
				else
					puts "Meehhh!!! state nix ausgecheckkt "+translations.size.to_s
				end 
			end
		end
		Geoname.transaction do
			geonames.each do |g| 
				translations = lookUpState[g.state_id]
				if !translations
					puts "state "+g.state_id.to_s+" not found for "+g.name 
					next
				end
				translations.each do |translation|
					if g != translation.geoname
						g.state = translation.geoname
						break
					else
						g.state = nil
					end
				end
				g.save
			end
		end
		puts "   -> Done."
		puts
	
  end


namespace :geonames do
	
  desc "download countries and import to postgis"
  task :countries => :environment do
	
		`rm #{temppath}/countryInfo.txt`
		`wget http://download.geonames.org/export/dump/countryInfo.txt \
							-O #{temppath}/countryInfo.txt`
	
		puts "-- importing countries.. "
		File.open("#{temppath}/countryInfo.txt", "r").each do |line|
			unless line.start_with? "#"
			  	c = line.split "\t"
		  		m = Country.new :iso => c[0], 
		  						:name => c[4], 
		  						:capital => c[5], 
		  						:area => c[6], 
		  						:population => c[7],
		  						:continent => c[8],
		  						:tld => c[9],
		  						:currency_code => c[10],
		  						:currency => c[11]
		  		m.iso = c[0]
		  		m.save
		  	end
		end
		puts "   -> Done."
		puts
  end
  
  
	
  desc "download altenate names and import to postgis"
  task :translations => :environment do
		
		`rm #{temppath}/alternateNames.*`
		`wget http://download.geonames.org/export/dump/alternateNames.zip \
								-O #{temppath}/alternateNames.zip`
		`unzip -d #{temppath}/ #{temppath}/alternateNames.zip`
	
		puts "-- importing translations.. "
		File.open("#{temppath}/alternateNames.txt", "r").each do |line|
			unless line.start_with? "#"
				t = line.split "\t"
			  	Translation.create :id => t[0],
			  						:iso => t[2], 
			  						:name => t[3], 
			  						:geoname_id => t[1], 
			  						:isShortName => t[5],
			  						:isPreferredName => t[4]
			end
		end

		puts "   -> Done."
		puts
  end
	
  desc "download top 15k cities and import to postgis"
  task :cities => :environment do
		
		`rm #{temppath}/cities15000.*`
		`wget http://download.geonames.org/export/dump/cities15000.zip \
								-O #{temppath}/cities15000.zip`
		`unzip -d #{temppath}/ #{temppath}/cities15000.zip`
	
		puts "-- importing top 1500 cities.. "
		File.open("#{temppath}/cities15000.txt", "r").each do |line|
			unless line.start_with? "#"
			  	g = line.split "\t"
			  	n = City.new
		  		n.id = g[0]
		  		n.name = g[1]
		  		n.state_id = g[10]
		  		n.timezone = g[17]
		  		n.population = g[14]
		  		n.country_iso = g[8]
			  	n.latlon = Place.find_by_sql("SELECT ST_GeomFromText(
			  				'POINT(#{g[5]} #{g[4]})', 4326)")[0].st_geomfromtext
			  	n.save unless City.exists? n.id
		  	end
		end

		puts "   -> Done."
		puts
  end
end
end	

