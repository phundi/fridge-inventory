ActiveRecord::Schema.define(version: 0) do

  change_table(:fridge) do |t|
    t.column :creator, :integer
  end

  change_table(:client) do |t|
    t.column :creator, :integer
  end
end

