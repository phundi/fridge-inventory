puts "Loading Conditions"
CSV.foreach("#{Rails.root}/app/assets/data/conditions.csv", :headers => false) do |row|
 next if row[0].blank?
 cond = Condition.create!(name: row[0].squish)
 puts "Loaded #{cond.name}"
end
puts "Loaded Conditions !!!"
