class FeedsController < ApplicationController
  before_filter :require_admin

  def index
    @feeds = Feed.all
  end
  
  def show
    @feed = Feed.find(params[:id])
  end
  
  def new
    @feed = Feed.new
  end
  
  def create
    @feed = Feed.new(params[:feed])
    if @feed.save
      flash[:notice] = "Successfully created feed."
      redirect_to @feed
    else
      render :action => 'new'
    end
  end
  
  def edit
    @feed = Feed.find(params[:id])
  end
  
  def update
    @feed = Feed.find(params[:id])
    if @feed.update_attributes(params[:feed])
      flash[:notice] = "Successfully updated feed."
      redirect_to @feed
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    flash[:notice] = "Successfully destroyed feed."
    redirect_to feeds_url
  end
end
