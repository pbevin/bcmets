class FeedEntriesController < ApplicationController
  def index
    @entries = FeedEntry.order("published_at DESC").paginate(page: params[:page])
  end
end
