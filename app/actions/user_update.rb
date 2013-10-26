class UserUpdate
  def initialize(id, attrs, current_user, is_admin)
    @id = id
    @attrs = attrs
    @current_user = current_user
    @is_admin = is_admin
  end

  def run
    if @id == 'current' || !@is_admin
      return :require_login if !@current_user
      user = @current_user
    else
      user = User.find(@id)
    end

    if user.update_attributes(@attrs)
      if @attrs[:active] && !user.active?
        user.activate!
      end
      user.update_mailman

      if @attrs[:photo].present?
        return :photo_updated
      else
        return :success
      end
    else
      return :failure
    end
  end
end
