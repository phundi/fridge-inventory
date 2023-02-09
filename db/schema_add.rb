ActiveRecord::Schema.define(version: 0) do

  create_table "activity", primary_key: "activity_id", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 200
    t.boolean  "voided",                      default: false, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "helpdesk_token", primary_key: "helpdesk_token_id", force: :cascade do |t|
    t.integer   "client_id",  null: false
    t.integer   "fridge_id",  null: false
    t.date  "token_date",  null: false        
    t.integer  "job_id"
    t.string  "status",  null: false
    t.string  "token_type"
    t.string   "description"        
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end
  
  create_table "service", primary_key: "service_id", force: :cascade do |t|
    t.integer   "client_id",  null: false
    t.integer   "fridge_id",  null: false
    t.date  "service_date",  null: false        
    t.integer  "job_id",  null: false
    t.string   "description"        
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end
  
  create_table "service_activity", primary_key: "service_activity_id", force: :cascade do |t|
    t.integer   "service_id",  null: false
    t.integer   "activity_id",  null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end
end


require Rails.root.join('db','load_activities.rb')
