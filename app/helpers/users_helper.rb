module UsersHelper
  def profile_picture_url(user)
    return nil if !user
    if user && user.photo.file? && File.exists?(user.photo.path)
      user.photo.url(:small)
    else
      nil
    end
  end

  def profile_picture(user, size = :medium)
    if user && user.photo.file? && File.exists?(user.photo.path)
      image_tag user.photo.url(size), class: 'profile'
    else
      ""
    end
  end

  def signin_props
    {
      user_session: {
        email: @user_session.email,
        password: @user_session.password
      }.merge(error_props(@user_session)),
      form: form_props(user_sessions_path)
    }
  end
end
