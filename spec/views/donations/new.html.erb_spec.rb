require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/donations/new.html.erb" do
  include DonationsHelper
  
  before(:each) do
    assigns[:donation] = stub_model(Donation,
      :new_record? => true,
      :email => "value for email",
      :amount => 1
    )
  end

  it "renders new donation form" do
    render
    
    response.should have_tag("form[action=?][method=post]", donations_path) do
      with_tag("input#donation_email[name=?]", "donation[email]")
      with_tag("input#donation_amount[name=?]", "donation[amount]")
    end
  end
end


