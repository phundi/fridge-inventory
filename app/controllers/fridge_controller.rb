class FridgeController < ApplicationController
  skip_before_action :verify_authenticity_token  

  def index
    @conditions = Condition.where(voided: 0)
  end

  def new
    @fridge = Fridge.new
    @action = "/fridge/new"
    @conditions = Condition.where(voided: 0)
    district_tag = LocationTag.where(name: "District").first 
    @districts = Location.find_by_sql("select * from location l INNER JOIN location_tag_map tm ON tm.location_id = l.location_id 
      WHERE tm.location_tag_id = #{district_tag.id}")

    @clients = Client.all

    if request.post?

      @fridge = Fridge.new
      @fridge.barcode_number = params[:barcode_number]
      @fridge.outlet_barcode_number = params[:outlet_barcode_number]
      @fridge.model = params[:model]
      @fridge.condition_id = params[:condition]
      @fridge.description = params[:description]
      @fridge.current_location = params[:district]
      @fridge.client_id = params[:owner]
      @fridge.creator = @cur_user.id
      @fridge.save

      redirect_to "/fridge/view?fridge_id=#{@fridge.id}"
    end
  end

  def edit
    @fridge = Fridge.find(params[:fridge_id])
    @action = "/fridge/edit"
    @conditions = Condition.where(voided: 0)
    district_tag = LocationTag.where(name: "District").first 
    @districts = Location.find_by_sql("select * from location l INNER JOIN location_tag_map tm ON tm.location_id = l.location_id 
      WHERE tm.location_tag_id = #{district_tag.id}")

    @client = Client.find(@fridge.client_id)

    @clients = Client.all

    if request.post?
      @fridge.barcode_number = params[:barcode_number]
      @fridge.outlet_barcode_number = params[:outlet_barcode_number]
      @fridge.model = params[:model]
      @fridge.condition_id = params[:condition]
      @fridge.description = params[:description]
      @fridge.current_location = params[:district]
      @fridge.client_id = params[:owner]
      @fridge.save

      redirect_to "/fridge/view?fridge_id=#{@fridge.id}"
    end
  end

  def helpdesk_token

    @fridge = Fridge.find(params[:fridge_id])
    @client= Client.find(@fridge.client_id)

    @statuses = ["New", "In Progress", "Closed"]
    @token_types = ["Service Request", "Other"]

    if request.post?

      token = HelpdeskToken.new
      token.client_id = @fridge.client_id 
      token.fridge_id = @fridge.id 
      token.status = params[:token_status]
      token.reported_by = params[:reported_by]
      token.token_date = params[:date_reported]
      token.creator = @cur_user.id
      token.description = params[:description].strip
      token.token_type = params[:token_type] 
      token.job_id = -1
      token.save

      redirect_to "/fridge/view?fridge_id=#{@fridge.id}" and return
    end 

    render :layout => "form"
  end 

  def verify

    outlet_barcode = params[:outlet_barcode]
    fridge_barcode = params[:fridge_barcode]

    by_outlet_barcode = Fridge.where(outlet_barcode_number: outlet_barcode).first 
    by_both = Fridge.where(outlet_barcode_number: outlet_barcode, 
                                    barcode_number: fridge_barcode).first
    by_fridge_barcode = Fridge.where(barcode_number: fridge_barcode).first 

    message = []
    if by_fridge_barcode.blank?
      message = [0, "Fridge Not Found"]
    else 
        v = Verification.new 
        v.outlet_barcode_number = outlet_barcode
        v.fridge_barcode_number = fridge_barcode
        v.client_id = by_outlet_barcode.client_id 
        v.creator = @cur_user.id 

        if by_both.present? 
          v.status = "Verified"
          message = [by_fridge_barcode.id, "Verified"]
        else 
          v.status = "Outlet Barcode Mismatch"
          wrong_client  = Client.find(by_fridge_barcode.client_id)
          v.description = "Fridge belongs to: #{wrong_client.name}"
          message = [by_fridge_barcode.id, v.description]
        end 

        v.save!
    end 

    render :text => message.to_json
  end 

  def new_verification

    @fridges = []
    if params[:outlet_barcode].present?
      @fridges = Fridge.where(outlet_barcode_number: params[:outlet_barcode])
    end

    if request.post?

      verification = Verification.new
      verification.client_id = @fridge.client_id 
      verification.fridge_id = @fridge.id 
      verification.save!


      redirect_to "/" and return
    end 
  end 

  def service

    @fridge = Fridge.find(params[:fridge_id])
    @client= Client.find(@fridge.client_id)
    @activities = Activity.all

    if request.post?

      service = Service.new
      service.client_id = @fridge.client_id 
      service.fridge_id = @fridge.id 
      service.service_date = params[:service_date]
      service.performed_by = params[:performed_by]
      service.creator = @cur_user.id
      service.description = params[:description].strip
      service.job_id = params[:job_id]
      service.save!

      (params[:service_activities] || []).each do |ac|
        ServiceActivity.create(
          service_id: service.id,
          activity_id: ac
        )
      end 

      redirect_to "/fridge/view?fridge_id=#{@fridge.id}" and return
    end 

    render :layout => "form"
  end 

    
  def view
    @fridge = Fridge.find(params[:fridge_id])
    @client = Client.find(@fridge.client_id)
    @trail_label = "Fridge History"
    @tokens = HelpdeskToken.where(fridge_id: @fridge.id).pluck :helpdesk_token_id
    @services = Service.where(fridge_id: @fridge.id).pluck :service_id 

    @modules = []
    @modules <<  ['Tokens', @tokens.count, "/fridge/all_tokens?fridge_id=#{@fridge.id}"]
    @modules <<  ['Services', @services.count, "/fridge/selected_services_done?fridge_id=#{@fridge.id}" ]


    @common_encounters = []
    @common_encounters << ['New Helpdesk Token', '/fridge/helpdesk_token']
    @common_encounters << ['Add Service Details', '/fridge/service']

    encounters = []

    @data = []
      @data << ({
          "title"   => "Fridge Registration",
          "content" => "Fridge assigned to new user: #{@client.name}",
          "data"    => [],
          "date"    => Time.now.strftime("%Y-%b-%d  &nbsp; %H:%M"),
          "user"    => User.first.name
  })

  end


  def ajax_fridges

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?

    tag_filter = ''
    code_filter = ''
    conditions = Condition.all.inject({}){|h, c| h[c.id] = c.name; h}
    client_filter = " "
    if params[:client_id].present?
      client_filter = " AND cl.client_id = #{params[:client_id]}"
    end 

    data = Fridge.joins(" LEFT JOIN location l ON l.location_id = fridge.current_location ")
            .joins(" LEFT JOIN client cl ON cl.client_id = fridge.client_id ")
            .order(' fridge.created_at DESC ')
    data = data.where(" (CONCAT_WS(l.name, cl.first_name, cl.last_name, outlet_barcode_number, model, fridge.description, '_') REGEXP '#{search_val}') 
      #{client_filter}
    ")
    total = data.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = data.select(" fridge.* ")
    data = data.page(page).per_page(params[:length].to_i)

    @records = []
    data.each do |f|
      cond = conditions[f.condition_id]
      location = Location.find(f.current_location).name
      owner = Client.find(f.client_id).name 
      row = [f.barcode_number, f.outlet_barcode_number, f.model, cond,  location, owner, f.id]
      @records << row
    end

    render :text => {
        "draw" => params[:draw].to_i,
        "recordsTotal" => total,
        "recordsFiltered" => total,
        "data" => @records}.to_json and return
  end

  def fridge_suggestions

    results = []
    if params['search_params']['outlet_barcode_number'].present?
      results = Fridge.where(" outlet_barcode_number = '#{params['search_params']['outlet_barcode_number']}' AND created_at IS NOT NULL");
    elsif params['search_params']['barcode_number'].present?
      results = Fridge.where(" barcode_number = '#{params['search_params']['barcode_number']}' AND created_at IS NOT NULL");
    end

    response = []
    (results || []).each do |result|
      response << {
          'barcode_number' => result.barcode_number,
          'outlet_barcode_number' => result.outlet_barcode_number,
          'model' => result.model,
          'location' => Location.find(result.current_location).name,
          'owner' => Client.find(result.client_id).name,
          'fridge_id' => result.id
      }
    end

    render text: response.to_json
  end

  def selected_services_done
    start_date, end_date = date_ranges
    @title = "Listing of Services Done"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model", "Service Date", 
    "Technician", "Service Activities", "Details", ""]

    client_filter = " "
    if params[:client_id].present?
      client_filter = " AND c.client_id = #{params[:client_id]}"
    end 

    fridge_filter = " "
    if params[:fridge_id].present?
      client_filter = " AND s.fridge_id = #{params[:fridge_id]}"
    end 

    Service.find_by_sql("
      SELECT 
        c.first_name, c.last_name, f.model, f.fridge_id, f.current_location, 
        s.performed_by, s.service_date, s.service_id, s.description, f.barcode_number 
      FROM service s 
        INNER JOIN fridge f ON f.fridge_id = s.fridge_id 
        INNER JOIN client c ON c.client_id = s.client_id
      WHERE s.service_date BETWEEN '#{start_date}' AND '#{end_date}' #{district_filter}
       #{client_filter} #{fridge_filter}
    ").each do |d|
      name = d.first_name + " " + d.last_name
      location = Location.find(d.current_location).name 
      @data << [name, location, d.barcode_number, d.model, d.service_date, d.performed_by, d.activities.join(","), d.description, d.service_id]
    end 

    render template: "fridge/generic_table"
  end 

  def selected_active_tokens
    start_date, end_date = date_ranges
    @title = "Listing of Active Helpdesk Tokens"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model", "Date Reported", 
    "Reported By", "Status", "Type", "Details"]

    HelpdeskToken.find_by_sql("
      SELECT 
        c.first_name, c.last_name, f.model, f.fridge_id, f.current_location, t.status, t.token_type,
        t.reported_by, t.token_date, t.helpdesk_token_id, t.description, f.barcode_number 
      FROM helpdesk_token t 
        INNER JOIN fridge f ON f.fridge_id = t.fridge_id 
        INNER JOIN client c ON c.client_id = t.client_id
      WHERE t.status IN ('New', 'In Progress') AND t.token_date BETWEEN '#{start_date}' AND '#{end_date}' #{district_filter}
    ").each do |d|
      name = d.first_name + " " + d.last_name
      location = Location.find(d.current_location).name 
      @data << [name, location, d.barcode_number, d.model, d.token_date, d.reported_by,
      d.status, d.token_type, d.description, d.helpdesk_token_id]
    end 

    render template: "fridge/generic_table"
  end

  def all_tokens
    start_date, end_date = date_ranges
    @title = "Listing of Helpdesk Tokens"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model", "Date Reported", 
    "Reported By", "Status", "Type", "Details"]

    client_filter = " "
    if params[:client_id].present?
      client_filter = " AND c.client_id = #{params[:client_id]}"
    end 

    fridge_filter = " "
    if params[:fridge_id].present?
      client_filter = " AND t.fridge_id = #{params[:fridge_id]}"
    end 

    HelpdeskToken.find_by_sql("
      SELECT 
        c.first_name, c.last_name, f.model, f.fridge_id, f.current_location, t.status, t.token_type,
        t.reported_by, t.token_date, t.helpdesk_token_id, t.description, f.barcode_number 
      FROM helpdesk_token t 
        INNER JOIN fridge f ON f.fridge_id = t.fridge_id 
        INNER JOIN client c ON c.client_id = t.client_id
      WHERE t.token_date BETWEEN '#{start_date}' AND '#{end_date}' #{district_filter} 
      #{client_filter}  #{fridge_filter}
    ").each do |d|
      name = d.first_name + " " + d.last_name
      location = Location.find(d.current_location).name 
      @data << [name, location, d.barcode_number, d.model, d.token_date, d.reported_by,
      d.status, d.token_type, d.description, d.helpdesk_token_id]
    end 

    render template: "fridge/generic_table"
  end

  def selected_pending_services
    start_date, end_date = date_ranges
    @title = "Listing of Pending Fridge Services"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model", "Date Reported", 
    "Reported By", "Status", "Type", "Details"]

    HelpdeskToken.find_by_sql("
      SELECT 
        c.first_name, c.last_name, f.model, f.fridge_id, f.current_location, t.status, t.token_type,
        t.reported_by, t.token_date, t.helpdesk_token_id, t.description, f.barcode_number 
      FROM helpdesk_token t 
        INNER JOIN fridge f ON f.fridge_id = t.fridge_id 
        INNER JOIN client c ON c.client_id = t.client_id
      WHERE t.status IN ('New', 'In Progress') 
      AND t.token_type = 'Service Request' AND t.token_date BETWEEN '#{start_date}' AND '#{end_date}' #{district_filter}
    ").each do |d|
      name = d.first_name + " " + d.last_name
      location = Location.find(d.current_location).name 
      @data << [name, location, d.barcode_number, d.model, d.token_date, d.reported_by,
      d.status, d.token_type, d.description, d.helpdesk_token_id]
    end 

    render template: "fridge/generic_table"
  end


  def selected_recorded_fridges
    start_date, end_date = date_ranges
    @title = "Listing of Recorded Fridges"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model",  "Condition",
               "Date Recorded", "Recorded By"]

    Fridge.find_by_sql("
          SELECT 
            c.first_name, c.last_name, f.model, f.fridge_id, f.current_location,
            f.barcode_number, f.fridge_id, f.condition_id, f.created_at, f.creator
          FROM fridge f
            INNER JOIN client c ON c.client_id = f.client_id
          WHERE true #{district_filter}    
            AND DATE(f.created_at) BETWEEN '#{start_date}' AND '#{end_date}'
      ").each do |d|
        name = d.first_name + " " + d.last_name
        location = Location.find(d.current_location).name 
        condition = Condition.find(d.condition_id).name
        u = User.find(d.creator)
        recorder = "#{u.first_name} #{u.last_name}"
        @data << [name, location, d.barcode_number, d.model, condition, d.created_at.to_date.to_s,
        recorder, d.fridge_id]
      end 

    render template: "fridge/generic_table"  
  end 

  def selected_verifications_done
    start_date, end_date = date_ranges
    @title = "Listing of Verifications"
    @data = []
    @data << ["Client Name", "Location", "Fridge Barcode", "Model",  "Condition",
               "Date Recorded", "Recorded By"]

    Fridge.find_by_sql("
          SELECT 
            c.first_name, c.last_name, f.model, f.fridge_id, f.current_location,
            f.barcode_number, f.fridge_id, f.condition_id, f.created_at, f.creator
          FROM fridge f
            INNER JOIN client c ON c.client_id = f.client_id

          WHERE true #{district_filter}    
            AND DATE(f.created_at) BETWEEN '#{start_date}' AND '#{end_date}'
      ").each do |d|
        name = d.first_name + " " + d.last_name
        location = Location.find(d.current_location).name 
        condition = Condition.find(d.condition_id).name
        u = User.find(d.creator)
        recorder = "#{u.first_name} #{u.last_name}"
        @data << [name, location, d.barcode_number, d.model, condition, d.created_at.to_date.to_s,
        recorder, d.fridge_id]
      end 

    render template: "fridge/generic_table"  
  end 

  private 
  def date_ranges 
    start_date, end_date = ["1900-01-01".to_date.to_s, Date.today.to_s]
    start_date = params[:start_date].to_date.to_s if params[:start_date].present?
    end_date = params[:end_date].to_date.to_s if params[:end_date].present?

    if params['period'].present?
      start_date, end_date = {
        "today" => [Date.today, Date.today],
        "week"  => [Time.now.beginning_of_week.to_date, Time.now.end_of_week.to_date],
        "month"  => [Time.now.beginning_of_month.to_date, Time.now.end_of_month.to_date],
        "year"  => [Time.now.beginning_of_year.to_date, Time.now.end_of_year.to_date],
        "eversince"  => ["1900-01-01".to_date.to_s, Date.today.to_s]
      }[params['period']]
    end 

    [start_date, end_date]
  end 

  def district_filter 
    district_filter = " "
    district_filter = " AND f.current_location = '#{params[:district_id]}' " if params[:district_id].present?
    district_filter
  end 

end
