require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  it "should be valid" do
    Feed.new.should be_valid
  end
end
