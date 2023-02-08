class FridgeController < ApplicationController
  

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

  def view
    @fridge = Fridge.find(params[:fridge_id])
    @client = Client.find(@fridge.client_id)
    @trail_label = "Fridge History"

    @modules = []
    @modules <<  ['Helpdesk Tokens', '2']
    @modules <<  ['Services', '0 Done' ]
    @modules <<  ['Relocations', '3'] 


    @common_encounters = []
    @common_encounters << ['New Helpdesk Token']
    @common_encounters << ['Add Service Details']
    @common_encounters << ['Change Owner']

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


    data = Fridge.order(' fridge.created_at DESC ')
    data = data.where(" (CONCAT_WS(serial_number, model, description, '_') REGEXP '#{search_val}') ")
    total = data.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = data.select(" fridge.* ")
    data = data.page(page).per_page(params[:length].to_i)

    @records = []
    data.each do |f|
      cond = conditions[f.condition_id]
      location = Location.find(f.current_location).name
      owner = Client.find(f.client_id).name 
      row = [f.serial_number, f.model, cond,  location, owner, f.id]
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
    results = Fridge.where(" serial_number = #{params['search_params']['serial_number']} AND created_at IS NOT NULL").limit(20);

    response = []
    (results || []).each do |result|
      response << {
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
