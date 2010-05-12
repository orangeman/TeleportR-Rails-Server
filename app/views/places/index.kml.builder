xml.instruct! :xml, :version=>"1.0" 
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
	xml.Document do
	xml.Style :id => "bus" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/a_bus.png")
		end
	  end	
	end
	xml.Style :id => "tram" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/a_tram.png")
		end
	  end	
	end
	xml.Style :id => "ubahn" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/a_ubahn.png")
		end
	  end	
	end
	xml.Style :id => "sbahn" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/a_sbahn.png")
		end
	  end	
	end
	xml.Style :id => "zug" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/a_zug.jpg")
		end
	  end	
	end
	xml.Style :id => "boot" do
      xml.IconStyle do
        xml.Icon do
          xml.href("http://may.base45.de:3000/images/ship.jpeg")
		end
	  end	
	end
		for p in @places do	
		   xml.Placemark do
		     xml.name p.name
		     xml.description "foo bar"
		     if p.modes&$BUS != 0
		     	xml.styleUrl "#bus" 
		     elsif p.modes&$TRAM != 0
		     	xml.styleUrl "#tram" 
		     elsif p.modes&$UBAHN != 0
		     	xml.styleUrl "#ubahn" 
		     elsif p.modes&$SBAHN != 0
		     	xml.styleUrl "#sbahn" 
			 elsif p.modes&$ZUG != 0
		     	xml.styleUrl "#zug" 
			 elsif p.modes&$BOOT != 0
		     	xml.styleUrl "#boot" 
		     end
		     latlon = p.latlon.match /(\d+\.\d+),(\d+\.\d+)/
		     xml.LookAt do
			  	xml.longitude  latlon[1].to_s
				xml.latitude latlon[2].to_s
				xml.altitude '3000'
  				xml.altitudeMode 'clampToGround'
		     end	
			 xml << p.latlon
		   end
		 end  
	end    
}
