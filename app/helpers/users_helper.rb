module UsersHelper
  def profile_picture(user, size = :medium)
#   if user.photo.file?
#     image_tag user.photo.url(size), :class => 'profile'
#   else
#     pixel_size = 100 # always for gravatar - they look silly at larger sizes.
#     gravatar_for user, :default => 'identicon', :size => pixel_size, :class => 'profile'
#   end
    options = {
      :default => "identicon",
      :size => 100
    }
    gravatar_image_tag(user.email, :class => "profile", :gravatar => options)
  end

  def profile_picture_linked(user)
    link_to(profile_picture(user, :small), user, :class => 'profile')
  end
end
