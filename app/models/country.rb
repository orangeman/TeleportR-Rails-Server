class Country < ActiveRecord::Base
	set_primary_key :iso
	has_many :cities, :primary_key => :iso, :foreign_key => :country_iso
	has_many :states, :primary_key => :iso, :foreign_key => :country_iso
end
