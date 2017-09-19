puts "Loading health facilities"

location_tag = LocationTag.where(name: 'Health facility').first

CSV.foreach("#{Rails.root}/app/assets/data/health_facilities.csv", :headers => true) do |row|
    next if row[2].blank?
    district = Location.where(name: row[0]).first
    health_facility = Location.create!(code: row[2], parent_location: district.id,
      name: row[3],
      description: "zone: #{row[4]} , fac_type: #{row[5]}, mga: #{row[6]}, f_type: #{row[7]}", 
      latitude: row[8], longitude: row[9])

    LocationTagMap.create(location_id: health_facility.id, location_tag_id: location_tag.id)
    puts "Loaded #{health_facility.name}"                                        
                                            
end
puts "Loaded health facilities !!!"
