class ModuleController < ApplicationController

  def view_module

    @client = Client.find(params[:client_id])
    @client_type = ClientType.find(@client.client_type_id).name
    @trail_label = "Patient #{params[:module]} History"

    @common_encounters = []
    @common_encounters << ['Presenting Complaints', "2", "complaints/#{@client.id}"]
    @common_encounters << ['Vitals', "34", "vitals/#{@client.id}"]
    @common_encounters << ['Diagnosis', '4', "diagnosis/#{@client.id}"]
    @common_encounters << ['Prescribe Drugs', '4', "prescribe/#{@client.id}"]
    @common_encounters << ['Dispense Drugs', '23', "dispense/#{@client.id}"]

    encounters = Encounter.where(client_id: params[:client_id],
                                 workflow_id: Workflow.where(name: params[:module]).first.id).order(" encounter_datetime DESC")

    @data = []
    encounters.each do |encounter|
      @data << ({
          "title"   => encounter.name,
          "content" => encounter.answer_string,
          "data"    => encounter.to_arr,
          "date"    => encounter.encounter_datetime.strftime("%Y-%b-%d  &nbsp; %H:%M"),
          "user"    => encounter.user
      } rescue next {})
    end
  end
end
