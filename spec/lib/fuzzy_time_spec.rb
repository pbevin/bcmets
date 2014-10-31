require 'spec_helper'

describe FuzzyTime do
  let(:now) { Time.new(2014, 10, 30, 19, 45, 18) }

  def fuzzy_time(tm)
    FuzzyTime.for(tm, now)
  end

  it "says Just Now if <1m" do
    fuzzy_time(now - 30.seconds).should == "Just now"
  end

  it "gives minutes ago if <1h" do
    fuzzy_time(now - 60.seconds).should == "1 minute"
    fuzzy_time(now - (59.minutes + 55.seconds)).should == "59 minutes"
  end

  it "gives hours ago if today" do
    fuzzy_time(now - 100.minutes).should == "1 hour"
    fuzzy_time(now - 200.minutes).should == "3 hours"
  end

  it "gives the time yesterday" do
    fuzzy_time(Time.new(2014, 10, 29, 23, 30, 44)).should ==
      "Yesterday, 11:30pm"
    fuzzy_time(Time.new(2014, 10, 29, 9, 3, 44)).should ==
      "Yesterday, 9:03am"
  end

  it "gives the DOW and time if in the last week" do
    fuzzy_time(now - 3.days).should == "Monday, 7:45pm"
  end

  it "gives the date and time if in the last month" do
    fuzzy_time(now - 10.days).should == "Oct 20, 7:45pm"
    fuzzy_time(Time.new(2014, 9, 30, 19, 46, 0)).should == "Sep 30, 7:46pm"
  end

  it "gives date if this year" do
    fuzzy_time(Time.new(2014, 9, 30, 19, 0, 0)).should == "Sep 30"
    fuzzy_time(Time.new(2014, 1, 1, 7, 0, 0)).should == "Jan 1"
  end

  it "gives date and year if before Jan 1" do
    fuzzy_time(Time.new(2013, 12, 30, 19, 0, 0)).should == "Dec 30, 2013"
  end



end

