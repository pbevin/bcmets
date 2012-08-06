require 'current_user'

module ApplicationHelper
  include CurrentUser
  def all_links
    Link.all(:order => "position")
  end
end
