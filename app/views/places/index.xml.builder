
xml.instruct! :xml, :version=>"1.0" 

xml.stations :version => "1.0", :timestamp => "1234" do

	for p in @places do
		
		if p.modes&$ZUG != 0
		
			latlon = p.latlon.match /(\d+\.\d+),(\d+\.\d+)/   # postgis db outputs a kml string
			xml.station p.name, 	:location => latlon[1] + " " + latlon[2],
						:locationY => latlon[1],
						:locationX => latlon[2] 
		end	
	end

end
