puts "TA's and Villages'"
file = File.open("#{Rails.root}/app/assets/data/districts.json").read

village_json = JSON.parse(file)
ta_location_tag = LocationTag.where(name: 'Traditional Authority').first
vlg_location_tag = LocationTag.where(name: 'Village').first

village_json.each do |district, traditional_authorities|
  district = Location.where(name: district).first

	traditional_authorities.each do |traditional_authority, villages|
	  ta = Location.create!(name: traditional_authority, parent_location: district.id)
    LocationTagMap.create(location_id: ta.id, location_tag_id: ta_location_tag.id)
    puts "Loaded TA  #{ta.name} of #{district.name} district" 

		villages.each do |village|	
      vlg = Location.create!(name: village, parent_location: ta.id) 
      LocationTagMap.create(location_id: vlg.id, location_tag_id: vlg_location_tag.id)
      puts "Loaded  #{vlg.name} village of  TA  #{ta.name} of #{district.name} district" 
		end
	
	end

end

puts "Loaded TA's and Villages'"
