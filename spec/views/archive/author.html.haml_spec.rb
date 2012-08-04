require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/author" do
  before(:each) do
    activate_authlogic
    @author = Article.make # hack
    assigns[:author] = @author
    @article1 = Article.make
    @article2 = Article.make
    assigns[:articles] = [@article1, @article2]
    render
  end

  it "should have the email in the title" do
    response.should have_selector("h1:contains('#{@author.email}')")
  end

  it "should list articles" do
    response.should have_selector "ul>li>a:contains('#{@article1.subject}')"
    response.should have_selector "ul>li>a:contains('#{@article2.subject}')"
  end

  it "should count articles" do
    response.should have_selector "p:contains('2 articles.')"
  end
end
