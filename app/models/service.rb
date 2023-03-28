class Service < ActiveRecord::Base
  self.table_name = :service
  self.primary_key = :service_id

  def activities 
    ServiceActivity.where(service_id: self.id).collect{|sa| Activity.find(sa.activity_id).name}.uniq
  end 
end
