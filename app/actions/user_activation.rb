class UserActivation
  attr_reader :user

  def initialize(user_id, username)
    @user_id = user_id
    @username = username
  end

  def run
    @user = User.find(@user_id)

    if user.update_attributes(@username) && user.activate!
      SubscriberEvent.queue.notify_created(user)
      UserSession.create(user)
      user.deliver_activation_confirmation!
      user.log_activation

      return true
    else
      return false
    end
  end
end
