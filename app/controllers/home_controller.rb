class HomeController < ApplicationController
  def index 

    district_tag = LocationTag.where(name: "District").first 
    @districts = Location.find_by_sql("select * from location l INNER JOIN location_tag_map tm ON tm.location_id = l.location_id 
      WHERE tm.location_tag_id = #{district_tag.id}")
  end

  def aggregate_data(start_date='1900-01-01', end_date=Date.today.to_s)
    data =  {}
    district_filter = ' '
    district_filter = " AND f.current_location = #{params[:district_id]} " if params[:district_id].present?

    data['pending_services'] = HelpdeskToken.find_by_sql("
    SELECT * FROM helpdesk_token t 
      INNER JOIN fridge f ON f.fridge_id = t.fridge_id
      WHERE true #{district_filter} AND t.token_date BETWEEN '#{start_date}' AND '#{end_date}'
     AND t.status IN ('New', 'In Progress') AND t.token_type = 'Service Request' "
  ).count 


    data['active_tokens'] = HelpdeskToken.find_by_sql("
        SELECT * FROM helpdesk_token t 
          INNER JOIN fridge f ON f.fridge_id = t.fridge_id
          WHERE true #{district_filter} AND t.token_date BETWEEN '#{start_date}' AND '#{end_date}'
         AND t.status IN ('New', 'In Progress')"
      ).count 

    data['services_done'] = Service.find_by_sql("
      SELECT * FROM service s
        INNER JOIN fridge f ON s.fridge_id = f.fridge_id
        WHERE true #{district_filter} AND s.service_date BETWEEN '#{start_date}' AND '#{end_date}'
    ").count

    data['recorded_fridges'] = Fridge.find_by_sql("
          SELECT * FROM fridge f WHERE true #{district_filter} 
            AND DATE(f.created_at) BETWEEN '#{start_date}' AND '#{end_date}'
        ").count

    data
  end 

  def aggregates
    data = aggregate_data('1900-01-01', Date.today)
    render text: data.to_json 
  end 

  def aggregates_by_period
      data = {
        "today" => aggregate_data(Date.today, Date.today),
        "week"  => aggregate_data(Time.now.beginning_of_week.to_date, Time.now.end_of_week.to_date),
        "month"  => aggregate_data(Time.now.beginning_of_month.to_date, Time.now.end_of_month.to_date),
        "year"  => aggregate_data(Time.now.beginning_of_year.to_date, Time.now.end_of_year.to_date),
        "eversince"  => aggregate_data
      }

      render text: data.to_json
  end 

end
