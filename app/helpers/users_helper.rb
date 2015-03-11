module UsersHelper
  def profile_picture_url(user)
    return nil if !user
    if user && user.photo.file?
      user.photo.url(:small)
    else
      nil
    end
  end
end
