require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/index" do
  before(:each) do
    assigns[:year] = 2009
    assigns[:month] = 3
    render 'archive/index'
  end
  
  it "should render years back to 2001" do
    (2001..2009).each do |year|
      response.should have_tag('h2', year.to_s)
    end
  end
  
  it "should have links for every month" do
    (2002..2008).each do |year|
      response.should have_tag('td>a', "March #{year}")
      response.should have_tag('td>a', "June #{year}")
      response.should have_tag('td>a', "September #{year}")
      response.should have_tag('td>a', "December #{year}")
    end
  end
  
  it "should highlight the current month" do
    response.should have_tag('td>a>strong', "March 2009")
  end
  
  it "should not link future months" do
    response.should have_tag('td', "April 2009")
    response.should_not have_tag('td>a', "April 2009")
  end
  
  it "should not render Jan 2001 as a link since it has no articles" do
    response.should have_tag('td>a', "January 2002")
    response.should have_tag('td', "January 2001")
    response.should_not have_tag("td>a", "January 2001")
  end
end
