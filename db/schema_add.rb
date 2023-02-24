ActiveRecord::Schema.define(version: 0) do

  change_table(:fridge) do |t|
    t.column :barcode_number, :string
  end
end

