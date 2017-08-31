class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_user, :except => ['logout', 'login']

  def check_user
    if session[:user_id].present?
      @cur_user = User.find(session[:user_id]) rescue (redirect_to '/logout' and return)
    else
      redirect_to "/logout"
    end
  end
end
