puts "Loading Countries"
countries = ISO3166::Country.all
countries_count = countries.count
puts countries.count.inspect + " Countries countries" 
location_tag  = LocationTag.where(name: 'Country').first

countries.each_with_index do |country, index|
  country = Location.create!(name: country.name, code: country.country_code, 
                             postal_code: country.alpha2, country: country.nationality, 
                             description: "continent: #{country.continent}, region: #{country.region}, sub_region: #{country.subregion}, world_region: #{country.world_region}, currency: #{(country.currency.name rescue '')},ioc: #{country.ioc}, gec: #{country.gec}")
  LocationTagMap.create!(location_id: country.id, 
                         location_tag_id: location_tag.id)

  puts "Loaded #{index + 1} of #{countries_count} countries"
end
puts "Loaded countries!!!"
