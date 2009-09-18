# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  before_filter :send_current_user
  
  def verify_current_user
    unless current_user
      redirect_to login_users_path
      return false
    else
      return true
    end
  end
  
  def current_user
    if session[:user_id]
      return User.find(session[:user_id]) || false
    else
      return false
    end
  end
  
  def send_current_user
    @current_user = current_user
  end
end
