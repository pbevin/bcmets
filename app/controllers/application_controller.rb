# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'current_user'

class ApplicationController < ActionController::Base
  include CurrentUser

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout :set_layout

  protected

  def require_admin
    if !view_context.logged_in_as_admin
      flash[:notice] = "Login first please"
      session[:return_to] = request.url
      redirect_to login_url
    end
  end

  def require_login
    if !view_context.current_user
      flash[:notice] = "Login first please"
      session[:return_to] = request.url
      redirect_to login_url
    end
  end

  def redirect_back_or_home
    redirect_to(session[:return_to] || root_path)
    session[:return_to] = nil
  end

  def set_layout
    if request.headers['X-PJAX']
      false
    else
      "application"
    end
  end
end
