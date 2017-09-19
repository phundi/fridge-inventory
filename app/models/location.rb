class Location < ActiveRecord::Base
  self.table_name = :location
  self.primary_key = :location_id

  def tags
    LocationTag.find_by_sql("SELECT t.* from location_tag_map m INNER JOIN location_tag t ON m.location_tag_id = t.location_tag_id
      WHERE m.location_id = #{self.id}")
  end
end
