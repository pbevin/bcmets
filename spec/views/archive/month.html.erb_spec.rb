require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/month" do
  before(:each) do
    @art1 = Article.create(:subject => "art1 title")
    @art2 = Article.create(:subject => "art2 subject", :parent_id => @art1.id)
    
    assigns[:articles] = [@art1, @art2]
    
    render 'archive/month'
  end
  
  it "should show articles" do
    response.should have_tag("a", @art1.subject)
    response.should have_tag("a", @art2.subject)
  end
  
  it "should put articles in conversation order"
  
  it "should list threads in reverse date order"
end
