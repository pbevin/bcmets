module CurrentUser
  def current_user
    @current_user ||= current_user_session && current_user_session.record
  end

  protected

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def logged_in_as_admin
    current_user && current_user.admin?
  end
end
