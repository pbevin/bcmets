module UsersHelper
  def profile_picture(user)
    if user.photo.present?
      image_tag @user.photo.url(:medium), :class => 'profile'
    else
      gravatar_for @user, :default => 'identicon', :size => 128
    end
  end
end
