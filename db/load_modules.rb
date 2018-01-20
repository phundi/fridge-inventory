puts "Loading Modules"
CSV.foreach("#{Rails.root}/app/assets/data/modules.csv", :headers => false) do |row|
 next if row[0].blank?
 workflow = Workflow.create!(name: row[0].squish)
 puts "Loaded #{workflow.name}"
end
puts "Loaded Modules !!!"