require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/article/show" do
  before(:each) do
    activate_authlogic

    @article = Article.make()
    assigns[:article] = @article
  end

  def do_render
    render 'articles/show'
  end
  
  it "should display article body" do
    do_render
    response.should have_tag('div#body', @article.body)
  end

  it "should have a Reply link if recent" do
    @article.stub!(:recent?).and_return(true)
    do_render
    response.should have_tag('a#reply[href=?]', article_reply_path(@article))
  end
    
  it "should not have a Reply link if ancient" do
    @article.stub!(:recent?).and_return(false)
    do_render
    response.should_not have_tag('a#reply')
  end
end
