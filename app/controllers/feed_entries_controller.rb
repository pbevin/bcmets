class FeedEntriesController < ApplicationController
  def index
    @entries = FeedEntry.all(:order => "published_at DESC")
  end
end