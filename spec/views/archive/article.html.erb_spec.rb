require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/article" do
  before(:each) do
    @article = Article.create(:subject => "subject", :body => "the body")
    assigns[:article] = @article
    render "archive/article"
  end
  
  it "should display article body" do
    response.should have_tag('div#body', @article.body)
  end

  it "should display links to other articles in thread"
  it "should show profile of sender"
  it "should have a Reply link if recent"
  it "should not have a Reply link if ancient"
  
end
