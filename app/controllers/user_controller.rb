class UserController < ApplicationController
  def index

  end

  def new
    if request.post?
      if !params[:image].blank?
        uploaded_io = params[:person][:picture]
        File.open(Rails.root.join('public', 'uploads', params[:username]), 'wb') do |file|
          file.write(uploaded_io.read)
        end
      end

      user = User.new(
          username: params[:username],
          first_name: params[:first_name],
          last_name: params[:last_name],
          password: params[:password],
          gender: params[:gender],
          designation: params[:designation]
      )

      user.email = params[:email] if !params[:email].blank?
      user.middle_name = params[:other_name] if !params[:other_name].blank?
      user.image =

      redirect_to '/user/index'
    end
  end

  def edit

  end
end
