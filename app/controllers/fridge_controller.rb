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
      @fridge.serial_number = params[:serial_number]
      @fridge.model = params[:model]
      @fridge.condition_id = params[:condition]
      @fridge.description = params[:description]
      @fridge.current_location = params[:district]
      @fridge.client_id = params[:owner]
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
      @fridge.serial_number = params[:serial_number]
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

    if request.post?

      token = HelpdeskToken.new
      token.client_id = @fridge.client_id 
      token.fridge_id = @fridge.id 
      token.status = params[:token_status]
      token.token_date = params[:date_reported]
      token.description = params[:description]
      token.token_type = "Service"
      token.job_id = -1
      token.save

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
    @modules <<  ['Helpdesk Tokens', @tokens.count]
    @modules <<  ['Services', @services.count ]
    @modules <<  ['Relocations', '0'] 


    @common_encounters = []
    @common_encounters << ['New Helpdesk Token', '/fridge/helpdesk_token']
    @common_encounters << ['Add Service Details', '/fridge/service']
    @common_encounters << ['Change Owner', '/fridge/relocate']

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


    data = Fridge.joins(" LEFT JOIN location l ON l.location_id = fridge.current_location ")
            .joins(" LEFT JOIN client cl ON cl.client_id = fridge.client_id ")
            .order(' fridge.created_at DESC ')
    data = data.where(" (CONCAT_WS(l.name, cl.first_name, cl.last_name, serial_number, model, fridge.description, '_') REGEXP '#{search_val}') ")
    total = data.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = data.select(" fridge.* ")
    data = data.page(page).per_page(params[:length].to_i)

    @records = []
    data.each do |f|
      cond = conditions[f.condition_id]
      location = Location.find(f.current_location).name
      owner = Client.find(f.client_id).name 
      row = [f.barcode_number, f.serial_number, f.model, cond,  location, owner, f.id]
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
    if params['search_params']['serial_number'].present?
      results = Fridge.where(" serial_number = '#{params['search_params']['serial_number']}' AND created_at IS NOT NULL");
    elsif params['search_params']['barcode_number'].present?
      results = Fridge.where(" barcode_number = '#{params['search_params']['barcode_number']}' AND created_at IS NOT NULL");
    end

    response = []
    (results || []).each do |result|
      response << {
          'barcode_number' => result.barcode_number,
          'serial_number' => result.serial_number,
          'model' => result.model,
          'location' => Location.find(result.current_location).name,
          'owner' => Client.find(result.client_id).name,
          'fridge_id' => result.id
      }
    end

    render text: response.to_json
  end
end
