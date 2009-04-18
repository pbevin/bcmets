require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/article" do
  before(:each) do
    @article = Article.make()
    assigns[:article] = @article
  end
  
  it "should display article body" do
    render "archive/article"
    response.should have_tag('div#body', @article.body)
  end

  it "should display links to other articles in thread"
  it "should show profile of sender"

  it "should have a Reply link if recent" do
    @article.stub!(:recent?).and_return(true)
    render 'archive/article'
    response.should have_tag('a#reply[href=?]', article_reply_path(@article))
  end
    
  it "should not have a Reply link if ancient" do
    @article.stub!(:recent?).and_return(false)
    render 'archive/article'
    response.should_not have_tag('a#reply')
  end
end
