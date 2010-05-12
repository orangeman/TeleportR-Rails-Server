class Geoname < ActiveRecord::Base

	belongs_to :state
	has_many :translations
	belongs_to :country, :primary_key => :iso, :foreign_key => :country_iso

end
