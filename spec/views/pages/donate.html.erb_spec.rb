require 'rails_helper'

describe "pages/donate" do
  it "should link to paypal" do
    render
    rendered.should have_selector("a[href^='https://www.paypal.com/']")
  end
end
