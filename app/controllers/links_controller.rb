class LinksController < ApplicationController
  before_filter :require_admin

  def index
    @links = Link.all
  end

  def show
    @link = Link.find(params[:id])
  end

  def new
    @link = Link.new
  end

  def edit
    @link = Link.find(params[:id])
  end

  def create
    @link = Link.new(link_params)

    if @link.save
      flash[:notice] = 'Link was successfully created.'
      redirect_to(@link)
    else
      render :action => "new"
    end
  end

  def update
    @link = Link.find(params[:id])
    if @link.update_attributes(link_params)
      flash[:notice] = 'Link was successfully updated.'
      redirect_to(@link)
    else
      render :action => "edit"
    end
  end

  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    redirect_to(links_url)
  end


  private

  def link_params
    params.require(:link).permit(:title, :url, :position)
  end
end
