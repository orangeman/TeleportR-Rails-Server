class Geoname < ActiveRecord::Base

	belongs_to :state
	has_many :translations
	belongs_to :country, :primary_key => :iso, :foreign_key => :country_iso


	def dist_to(another)
      Place.find_by_sql("SELECT ST_Distance('#{latlon}', '#{another.latlon}')")[0].st_distance.to_f*200 #km
    end
    
end

