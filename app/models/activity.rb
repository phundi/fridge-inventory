class Activity < ActiveRecord::Base
  self.table_name = :activity
  self.primary_key = :activity_id
end
