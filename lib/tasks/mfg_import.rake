# coding: utf-8


namespace :import do
namespace :mfg do


  desc "get city ids from mitfahrgelegenheit.de"
  task :cities => :environment do

	html = Net::HTTP.get URI.parse('http://www.mitfahrgelegenheit.de')
	cities = html.match(/<option([\s\S]*?)<\/select>/)[1].scan(/value="(\d+)">(.*)<\/option>/)
	
	cities.each do |c|
		if City.find_by_name c[1]
			puts c[0]+" -> "+c[1]
		else
			puts c[1]+" is unknown."
		end
	end

  end







  def escape(str)
    str.gsub!(/&(.+);/n) {
      case $1
        when 'auml'  then 'ä'
        when 'ouml'  then 'ö'
        when 'uuml'  then 'ü'
        when 'Auml'  then 'Ä'
        when 'Ouml'  then 'Ö'
        when 'Üuml'  then 'Ü'
        when 'szlig'  then 'ß'
      end
    }
    str.gsub! '.', ''
    str.gsub! '(', ''
    str.gsub! ')', ''
    str.gsub! '/ ', ' '
    str.gsub! '/', ' '
    
    str.gsub! ' ad ', ' an der '
    str.gsub! ' id ', ' in der '
    str.gsub! /Allg(\s|)$/, 'Allgäu'
    str.gsub! 'Schwnd', 'Schwand'
    str.gsub! 'München Flughafen', 'Flughafen München Airport'
    str.gsub! 'Rothenburg Tauber', 'Rothenburg o d Tauber'
    str
  end


end
end
   
