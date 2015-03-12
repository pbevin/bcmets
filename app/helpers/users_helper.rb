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
end
