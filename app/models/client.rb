class Client < ActiveRecord::Base
 self.table_name = 'client'
 self.primary_key = 'client_id'

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def age
    -1
  end

  def sex
    {0 => "F", 1 => "M"}[self.gender]
  end
end
