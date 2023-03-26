ActiveRecord::Schema.define(version: 0) do

  change_table(:service) do |t|
    t.column :performed_by, :string
    t.column :creator, :integer
  end
end

