class ConfigurationController < ApplicationController

  def index
    modul = params[:module]
    case modul
      when 'lab'
        render :template => "configuration/lab"
      when 'opd'

      when 'billing'

      when 'art'

      when 'anc'

      when 'maternity'
    end
  end
end
