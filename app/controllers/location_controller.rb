class LocationController < ApplicationController
  def index
    tag = params[:tag] || 'Workstation'
    tag_id = LocationTag.where(name: tag).last.id
    @locations = Location.find_by_sql("SELECT l.* from location l INNER JOIN location_tag_map m
                              ON l.location_id = m.location_id AND m.location_tag_id = #{tag_id} LIMIT 20")

  end

  def tags
    @location_tags = LocationTag.where(" voided = 0 ").order('name')
  end

  def new
    @location = Location.new
    @tags = LocationTag.all.each_slice(4).to_a
    @action = "/location/new"
    if request.post?
      l = Location.create(
          name: params[:name],
          code: params[:code],
          description: params[:description]
      )

      (params[:tags] || []).each do |tag|
        LocationTagMap.create(location_id: l.id, location_tag_id: tag)
      end
      redirect_to "/location/index" and return
    end
  end

  def edit
    @action = "/location/edit"
    @location_tag = Location.find(params[:location_id])
    if request.post?
      @location.name = params[:name]
      @location.description = params[:description]
      @location.save
      redirect_to "/location/index" and return
    end
  end

  def view
    @location = Location.find(params[:location_id])
  end

  def delete
    tag_maps = LocationTagMap.find_by_sql("SELECT * FROM location_tag_map WHERE location_tag_id = #{params[:tag_id]}")
    if tag_maps.blank?
      tag = LocationTag.find(params[:tag_id])
      tag.destroy
      flash[:error] = "Successfully deleted location type"
    else
      flash[:error] = "Location already in use by #{tag_maps.count} tag items"
    end

    redirect_to '/location/tags'
  end

  def new_tag
    @location_tag = LocationTag.new
    @action = "/location/new_tag"
    if request.post?
      LocationTag.create(name: params[:name], description: params[:description])
      redirect_to "/location/tags" and return
    end
  end

  def edit_tag
    @action = "/location/edit_tag"
    @location_tag = LocationTag.find(params[:tag_id])
    if request.post?
      @location_tag.name = params[:name]
      @location_tag.description = params[:description]
      @location_tag.save
      redirect_to "/location/tags" and return
    end
  end

  def view_tag
    @location_tag = LocationTag.find(params[:tag_id])
  end

  def delete_tag
    tag_maps = LocationTagMap.find_by_sql("SELECT * FROM location_tag_map WHERE location_tag_id = #{params[:tag_id]}")
    if tag_maps.blank?
      tag = LocationTag.find(params[:tag_id])
      tag.destroy
      flash[:error] = "Successfully deleted location type"
    else
      flash[:error] = "Location type already in use by #{tag_maps.count} items"
    end

    redirect_to '/location/tags'
  end
end
