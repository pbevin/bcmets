# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def all_links
    Link.all(:order => "position")
  end
end
