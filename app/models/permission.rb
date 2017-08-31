class Permission < ActiveRecord::Base
  self.table_name = :permission
  self.primary_key = :permission_id
end
