class Client < ActiveRecord::Base
 self.table_name = 'client'
 self.primary_key = 'client_id'
end
