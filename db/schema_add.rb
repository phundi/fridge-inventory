ActiveRecord::Schema.define(version: 0) do

  change_table(:helpdesk_token) do |t|
    t.column :reported_by, :string
    t.column :creator, :integer
  end
end

