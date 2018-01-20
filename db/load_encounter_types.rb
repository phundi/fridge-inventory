puts "Loading Location Tags"
CSV.foreach("#{Rails.root}/app/assets/data/location_tags.csv", :headers => false) do |row|
 next if row[0].blank?
 location_tag = LocationTag.create!(name: row[0].squish, locked: 1)
 puts "Loaded #{location_tag.name}"
end
puts "Loaded Location Tags !!!"