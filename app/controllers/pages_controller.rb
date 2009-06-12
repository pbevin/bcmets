class PagesController < ApplicationController
  layout "archive"
  before_filter :allow_search_engines
  
  def index
    redirect_to '/'
  end
  
  def howto
    
  end

private

  def allow_search_engines
    @indexable = true
  end
end
