
puts "Loading Districts"

location_tag = LocationTag.where(name: 'District').first

CSV.foreach("#{Rails.root}/app/assets/data/districts_with_codes.csv", :headers => true) do |row|
 next if row[0].blank?
 district = Location.create!(code: row[0], name: row[1], description: row[2])
 LocationTagMap.create(location_id: district.id, location_tag_id: location_tag.id)
 puts "Loaded #{district.name}"

  if district.name.match(/city/i)
    if district.name.match(/Blantyre/i)
      l = Location.where(name: 'Blantyre').first
    elsif district.name.match(/Lilongwe/i)
      l = Location.where(name: 'Lilongwe').first
    elsif district.name.match(/Mzuzu/i)
      l = Location.where(name: 'Mzimba').first
    elsif district.name.match(/Zomba/i)
      l = Location.where(name: 'Zomba').first
    end
    
    district.update_attributes(parent_location: l.id)
  end
end
puts "Loaded Districts of Malawi !!!"
