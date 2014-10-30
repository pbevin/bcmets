module UsersHelper
  def profile_picture(user, size = :medium)
    if user.photo.file?
      image_tag user.photo.url(size), class: 'profile'
    else
      options = {
        default: "identicon",
        size: 100
      }
      gravatar_image_tag(user.email, class: "profile", gravatar: options)
    end
  end

  def avatar_url(user, size = :medium)
    if user && user.photo.file?
      user.photo.url(size)
    else
      nil
    end
  end

  def profile_picture_linked(user)
    link_to(profile_picture(user, :small), user, class: 'profile')
  end
end
