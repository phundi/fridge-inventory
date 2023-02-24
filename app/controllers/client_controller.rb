class ClientController < ApplicationController
  def client_types
    @client_types = ClientType.where(voided: 0).order('name')
  end

  def index
    @types = ClientType.where(voided: 0)
  end

  def new
    @client = Client.new
    @action = "/client/new"
    @types = ClientType.where(voided: 0)

    if request.post?
      @client = Client.new
      @client.client_type_id = params[:type]
      @client.first_name = params[:first_name]
      @client.identifier = params[:identifier]
      @client.business_certificate = params[:business_certificate]
      @client.first_name_code = params[:first_name].soundex
      @client.last_name = params[:last_name]
      @client.last_name_code = params[:last_name].soundex
      @client.middle_name = params[:middle_name]
      @client.gender = params[:gender]
      @client.birthdate = params[:birthdate].to_date
      @client.phone_number = params[:phone_number]
      @client.email = params[:email]
      @client.address = params[:address] rescue nil
      @client.occupation = params[:occupation]
      @client.save
      redirect_to "/client/view?client_id=#{@client.id}"
    end
  end

  def edit
    @client = Client.find(params[:client_id])

    @action = "/client/edit"
    @types = ClientType.where(voided: 0)

    if request.post?
      @client.client_type_id = params[:type]
      @client.identifier = params[:identifier]
      @client.business_certificate = params[:business_certificate]
      @client.first_name = params[:first_name]
      @client.first_name_code = params[:first_name].soundex
      @client.last_name = params[:last_name]
      @client.last_name_code = params[:last_name].soundex
      @client.middle_name = params[:middle_name]
      @client.gender = params[:gender]
      @client.birthdate = params[:birthdate].to_date
      @client.phone_number = params[:phone_number]
      @client.email = params[:email]
      @client.address = params[:address] rescue nil
      @client.occupation = params[:occupation]
      @client.save
      redirect_to "/client/view?client_id=#{@client.id}"
    end
  end

  def view
    @client = Client.find(params[:client_id])
    @client_type = ClientType.find(@client.client_type_id).name
    @trail_label = "Client History"

    @modules = []
    @modules <<  ['Fridges', '4 Assigned']
    @modules <<  ['Service Orders', 'None']
    @modules <<  ['Total Services', '3 Done'] 


    @common_encounters = []
    @common_encounters << ['Assign Fridge']
    @common_encounters << ['Remove Fridge']
    @common_encounters << ['Blacklist']


    encounters = [] #Encounter.where(client_id: params[:client_id]).order(" encounter_datetime DESC")

    @data = []
    encounters.each do |encounter|
      @data << ({
          "title"   => encounter.name,
          "content" => encounter.answer_string,
          "data"    => encounter.to_arr,
          "date"    => encounter.encounter_datetime.strftime("%Y-%b-%d  &nbsp; %H:%M"),
          "user"    => encounter.user
      } rescue next)
    end
  end

  def new_type
    @client_type = ClientType.new
    @action = "/client/new_type"
    if request.post?
      ClientType.create(name: params[:name], description: params[:description], voided: 0)
      redirect_to "/client/client_types" and return
    end
  end

  def view_type
    @client_type = ClientType.find(params[:type_id])
  end

  def edit_type
    @action = "/client/edit_type"
    @client_type = ClientType.find(params[:type_id])
    if request.post?
      @client_type.name = params[:name]
      @client_type.description = params[:description]
      @client_type.save
      redirect_to "/client/client_types" and return
    end
  end

  def delete_type
    type = ClientType.find(params[:type_id])
    type.voided = 1
    type.save
    redirect_to '/client/client_types'
  end

  def ajax_clients

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?

    tag_filter = ''
    code_filter = ''
    c_types = ClientType.all.inject({}){|h, c| h[c.id] = c.name; h}

    if (params[:search][:value] rescue nil).present?
      search_code = search_val.soundex rescue '_'
      code_filter = " OR first_name_code = '#{search_code}' OR last_name_code = '#{search_code}'"
    end

    if params[:type_id].present?
      tag_filter = " AND client.client_type_id = #{params[:type_id]}"
    end

    data = Client.order(' client.created_at DESC ')
    data = data.where(" ((CONCAT_WS(first_name, middle_name, last_name, identifier, gender, birthdate, address, email, occupation, phone_number, '_') REGEXP '#{search_val}')
         #{tag_filter}) #{code_filter}")
    total = data.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = data.select(" client.* ")
    data = data.page(page).per_page(params[:length].to_i)

    @records = []
    data.each do |p|
      gender = p.gender.to_i == 1 ? "M" : 'F'
      type = c_types[p.client_type_id]
      name = "#{p.first_name} #{p.middle_name} #{p.last_name}(#{gender})".gsub(/\s+/, ' ')
      #dob = p.birthdate.to_date.strftime("%d-%b-%Y") rescue nil
      row = [name, p.identifier, p.business_certificate, type, p.phone_number, p.address, p.id]
      @records << row
    end

    render :text => {
        "draw" => params[:draw].to_i,
        "recordsTotal" => total,
        "recordsFiltered" => total,
        "data" => @records}.to_json and return
  end

  def client_suggestions
    query = " "
    (params[:search_params] || []).each do |k, v|
      next if v.blank?

      if k == 'first_name'
        k = 'first_name_code'
        v = v.soundex
      end

      if k == 'last_name'
        k = 'last_name_code'
        v = v.soundex
      end

      if k == 'birthdate'
        v = v.to_date.strftime('%Y-%m-%d')
      end

      if k == 'gender'

      end

      query += " AND #{k} RLIKE '#{v}' "
    end

    results = []
    if query.strip.length > 0
      results = Client.where(" created_at IS NOT NULL #{query}").limit(20);
    end

    response = []
    (results || []).each do |result|
      gender = result.gender.to_i == 1 ? "M" : 'F'
      response << {
          'dob' => result.birthdate.to_date.strftime("%d-%b-%Y"),
          'occupation' => result.occupation,
          'name' => "#{result.first_name} #{(result.middle_name.split('')[0] rescue '')} #{result.last_name} (#{gender})".gsub(/\s+/, ' '),
          'address' => result.address,
          'phone_number' => result.phone_number,
          'client_id' => result.id
      }
    end

    render text: response.to_json
  end
end
