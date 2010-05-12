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

namespace :export do

namespace :downloads do
  
  desc "download osm data to postgis and extract streets and stopps"
  task :osm => [:cities, :hm]
  task :cities => :environment do
  	c = ENV["c"]
  	if not c
  		puts "MEHH"
  		break
  	end
 	puts "oha"
  end
  task :hm => :environment do
 	puts "hm"
  end
end
end
	

