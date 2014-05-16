require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Donation do
  it "should be valid" do
    Donation.make!.should be_valid
  end

  it "should require all fields" do
    Donation.make(date: nil).should_not be_valid
    Donation.make(amount: nil).should_not be_valid
    Donation.make(email: nil).should_not be_valid
  end
end

describe Donation, "summaries" do
  before(:each) do
    @d1 = Donation.make!(date: DateTime.parse("December 31, 2008"), amount: 10)
    @d2 = Donation.make!(date: DateTime.parse("March 15, 2009"), amount: 20)
    @d3 = Donation.make!(date: DateTime.parse("April 15, 2009"), amount: 40)
  end

  it "should count current month's donations" do
    Donation.total_this_month(DateTime.parse("April 20, 2009")).should == @d3.amount
  end

  it "should count current year's donation" do
    Donation.total_this_year(DateTime.parse("April 20, 2009")).should == @d2.amount + @d3.amount
  end

  it "should reset on the first of the month" do
    Donation.total_this_month(DateTime.parse("May 1, 2009")).should == 0
    Donation.total_this_year(DateTime.parse("Jan 1, 2010")).should == 0
  end
end
