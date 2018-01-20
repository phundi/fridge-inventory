class EncounterController < ApplicationController
  skip_before_action :verify_authenticity_token

  def complaints
    @client = Client.find(params[:client_id])
    @client_type = ClientType.find(@client.client_type_id).name
    @trail_label = "Previous Complaints History"
    @complaints = ["", "Headache", "Leg Pains", "Stomach Pains", "Eye Tearing"]

    @data = [{
                 "title"   => "",
                 "content" => "Temperature: 39 oC, Height: 165cm, BP: 66/98 - <span class='cost'>K90</span>",
                 "data"    => [["Temperature Reading", "Value1"], ["Drug2", "Value 2 pills"], ["Concept1", "Value1"], ["Drug2", "Value 2 pills"]],
                 "date"    => 9.days.ago.strftime("%Y-%b-%d  &nbsp; %H:%M"),
                 "user"    => "Test User"
             },

             {
                 "title"   => "",
                 "content" => "29 tabs Paracetamol, 2 Inject DCN - <span class='cost'>K1200</span>",
                 "data"    => [["Concept1", "Value1"], ["Drug2", "Value 2 pills"]],
                 "date"    => 7.days.ago.strftime("%Y-%b-%d &nbsp; %H:%M"),
                 "user"    => "Test User"
             }].sort_by{|h| h['date']}

    render :layout => "form"
  end

  def create

    raise params.inspect
  end
end
