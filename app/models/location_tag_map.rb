class LocationTagMap < ActiveRecord::Base
  self.table_name = :location_tag_map
  has_one :location_tag
end
