require 'current_user'

module ApplicationHelper
  include CurrentUser

  def all_links
    Link.order("position")
  end
end
