class TimelineController < ApplicationController
  def index
    @posts = Article.order("received_at DESC").first(10)
  end
end
