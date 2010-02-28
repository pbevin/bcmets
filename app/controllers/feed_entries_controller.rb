class FeedEntriesController < ApplicationController
  def index
    @entries = FeedEntry.paginate :page => params[:page], :order => "published_at DESC"
  end
end