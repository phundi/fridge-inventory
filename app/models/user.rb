class User < ActiveRecord::Base
  self.table_name = :user
  self.primary_key = :user_id
end
