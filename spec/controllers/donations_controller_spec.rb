require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      controller.stub(:require_admin => true)
    end

    describe "GET index" do
      it "returns the donations list" do
        list = [Donation.new]
        Donation.should_receive(:all).and_return(list)
        get :index
        assigns(:donations).should == list
      end
    end
  end
end
