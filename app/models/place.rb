class Place < ActiveRecord::Base

  belongs_to :state

	
  def dist_to(another)
    Place.find_by_sql("SELECT ST_Distance('#{latlon}', '#{another.latlon}')")[0].st_distance.to_f*200 #km
  end
  
  
  def hash
    [name, modes].hash
  end

  def eql?(other)
    [name, modes].eql?([other.name, other.modes])
  end

end
