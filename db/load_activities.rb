puts "Loading Activities"
CSV.foreach("#{Rails.root}/app/assets/data/activities.csv", :headers => false) do |row|
 next if row[0].blank?
 ac = Activity.create!(name: row[0].squish)
 puts "Loaded #{ac.name}"
end
puts "Loaded Activities !!!"
