class DonationsController < ApplicationController 
  # GET /donations/stats
  def stats
    render :text => "#{Donation.total_this_month} #{Donation.total_this_year}"
  end
end
