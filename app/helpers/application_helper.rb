require 'current_user'

module ApplicationHelper
  include CurrentUser

  def all_links
    Link.order("position")
  end

  def link(text, opts={})
    link_to text, "javascript:void(0)", opts
  end
end
