# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  helper_method :current_user  
  hide_action :current_user

  
  def current_user
    return @current_user if @current_user
    @current_user = current_user_session && current_user_session.record
  end

  private

  def current_user_session
    return @current_user_session if @current_user_session
    @current_user_session = UserSession.find
  end
  
  def require_user 
    unless current_user 
      flash[:notice] = "You must be logged in to access this page" 
      redirect_to login_path 
      return false 
    end 
  end 

  def require_no_user 
    if current_user 
      flash[:notice] = "You must be logged out to access this page" 
      redirect_to root_url 
      return false 
    end 
  end

  def logged_in_as_admin
    current_user && current_user.email == 'pete@petebevin.com'
  end

  def require_admin
    if !logged_in_as_admin
      flash[:notice] = "Login first please"
      session[:return_to] = request.request_uri
      redirect_to login_url
    end
  end

  def redirect_back_or_home
    redirect_to(session[:return_to] || root_path)
    session[:return_to] = nil
  end
end
