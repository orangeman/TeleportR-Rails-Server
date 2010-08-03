# coding: utf-8


namespace :import do
namespace :rmv do


  desc "read transit agency list from rmv.de"
  task :agencies => :environment do

	r = Net::HTTP.get URI.parse "http://www.rmv.de/coremedia/generator/RMV/Verkehrshinweise/AndereVerkehrsverbuende.html"
	r.scan(/class=\"h5_partnername\">(.*)<[\s\S]*?href=\"(.*?)\"/).each { |s| Plugin.create :title => s[0], :url => s[1] }

  end


end
end
   
