module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the front\s?page/
      '/'

    when /Login/
      '/login'

    when /the "([^"]*)" archive page/
      "/archive/#{$1}"

    when /path (.+)$/
      path = $1
      if path =~ /"(.+)"/
        path = $1
      end
      path

    when "View Users"
      "/users"

    when "Show Links"
      "/links"

    when "Donations"
      donations_path

    when "the article", "that article"
      article_path(@article)

    when "the parent article"
      article_path(@parent)

    when /Edit User for (.+)/
      edit_user_path(@user)

    when "my profile"
      "/users/current/edit"

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      fail "Can't find mapping from \"#{page_name}\" to a path.\n" \
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
