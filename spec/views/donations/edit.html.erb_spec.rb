require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/donations/edit.html.erb" do
  include DonationsHelper
  
  before(:each) do
    assigns[:donation] = @donation = stub_model(Donation,
      :new_record? => false,
      :email => "value for email",
      :amount => 1
    )
  end

  it "renders the edit donation form" do
    render
    
    response.should have_tag("form[action=#{donation_path(@donation)}][method=post]") do
      with_tag('input#donation_email[name=?]', "donation[email]")
      with_tag('input#donation_amount[name=?]', "donation[amount]")
    end
  end
end


