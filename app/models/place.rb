class Place < ActiveRecord::Base

	belongs_to :state
	has_and_belongs_to_many :downloads
	
	
	
  def distance_to(other)
    ((lat - other.lat)**2 + (lng - other.lng)**2) / 10000000
  end
  
  
  def hash
    [name, modes, city_id].hash
  end

  def eql?(other)
    [name, modes, city_id].eql?([other.name, other.modes, other.city_id])
  end


end
