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

  def lab_departments
    @departments = Department.all
    render :template => "/configuration/lab/departments", :layout => "plain"
  end

  def new_department
    @department = Department.new

    if request.post?
      if Department.where(name: params[:name]).length > 0
        raise "Department Already Exists".to_s
      end

      @department.name = params[:name]
      @department.description = params[:description]
      @department.save

      redirect_to "/lab_departments" and return
    end

    render :template => "/configuration/lab/department_form", :layout => "plain"
  end

  def edit_department
    @department = Department.find(params[:id])

    if request.post?
      if Department.where(name: params[:name]).length > 0
        raise "Department Already Exists".to_s
      end

      @department.name = params[:name]
      @department.description = params[:description]
      @department.save

      redirect_to "/lab_departments" and return
    end

    render :template => "/configuration/lab/department_form", :layout => "plain"
  end

  def delete_department
    @department = Department.find(params[:id])
    @department.voided = true
    @department.voided_by =  @cur_user
    @department.void_reason = "N/A"
  end
end
