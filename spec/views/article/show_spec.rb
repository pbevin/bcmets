require 'spec_helper'

describe "articles/show" do
  before(:each) do
    @article = Article.make!
    assigns[:article] = @article
  end

  it "should display article body" do
    render
    rendered.should have_selector 'div#body',
      :text => @article.body
  end

  it "should have a Reply link if recent" do
    @article.stub!(:recent?).and_return(true)
    render
    rendered.should have_selector "a#reply"
  end

  it "should not have a Reply link if ancient" do
    @article.stub!(:recent?).and_return(false)
    render
    rendered.should_not have_selector "a#reply"
  end
end
