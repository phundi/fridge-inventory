puts "Loading Encounter Types"
CSV.foreach("#{Rails.root}/app/assets/data/encounter_types.csv", :headers => false) do |row|
 next if row[0].blank?
 type = EncounterType.create!(name: row[0].squish)
 puts "Loaded #{type.name}"
end
puts "Loaded Encounter Types !!!"