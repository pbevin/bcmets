require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/month" do
  before(:each) do
    @art1 = Article.make(:sent_at => DateTime.parse("2009-03-28 13:00:00"))
    @art2 = Article.make(:sent_at => DateTime.parse("2009-03-29 04:00:00"), :parent_id => @art1.id)
    
    assigns[:articles] = [@art1, @art2]
    
    render 'archive/month'
  end
  
  it "should show articles" do
    response.should have_tag("a.subject", @art1.subject)
    response.should have_tag("a.subject", @art2.subject)
  end
  
  it "should put articles in conversation order"
  
end
