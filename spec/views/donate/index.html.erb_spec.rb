require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/donate/index" do
  before(:each) do
    render 'donate/index'
  end
  
  it "should link to paypal" do
    response.should have_tag("a[href^=https://www.paypal.com/]")
  end
end
