class DonationsController < ApplicationController
  before_filter :require_admin, :except => :stats

  def index
    @donations = Donation.all(:order => 'date DESC')
  end

  def show
    @donation = Donation.find(params[:id])
  end

  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(params[:donation])
    if @donation.save
      flash[:notice] = "Successfully created donation."
      redirect_to donations_path
    else
      render :action => 'new'
    end
  end

  def edit
    @donation = Donation.find(params[:id])
  end

  def update
    @donation = Donation.find(params[:id])
    if @donation.update_attributes(params[:donation])
      flash[:notice] = "Successfully updated donation."
      redirect_to @donations
    else
      render :action => 'edit'
    end
  end

  def destroy
    @donation = Donation.find(params[:id])
    @donation.destroy
    flash[:notice] = "Successfully destroyed donation."
    redirect_to donations_url
  end

  def stats
    render :text => "#{Donation.total_this_month} #{Donation.total_this_year}"
  end
end
