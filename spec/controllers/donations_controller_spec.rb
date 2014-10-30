require 'rails_helper'

describe DonationsController do
  describe "GET stats" do
    it "gives me the monthly and yearly totals" do
      Donation.should_receive(:total_this_month).and_return("monthly")
      Donation.should_receive(:total_this_year).and_return("yearly")
      get :stats
      response.body.should == "monthly yearly"
    end
  end

  context "admin functions" do
    before(:each) do
      controller.stub(require_admin: true)
    end

    describe "GET index" do
      it "returns the donations list" do
        donation = Donation.create!(email: "test@example.com", amount: "15.00", date: Date.yesterday)
        get :index
        assigns(:donations).should == [ donation ]
      end
    end
  end
end
