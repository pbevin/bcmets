require 'rails_helper'

describe "/archive/author" do
  before(:each) do
    @email = "test@example.com"
    @article1 = Article.make
    @article2 = Article.make
    assign(:articles, [@article1, @article2])
    assign(:email, @email)
    render
  end

  it "should have the email in the title" do
    rendered.should have_selector("h1") do |h1|
      h1.should contain(@email)
    end
  end

  it "should list articles" do
    rendered.should have_selector "ul>li>a:first" do |a|
      a.should contain(@article1.subject)
    end
    rendered.should have_selector "ul>li>a:last" do |a|
      a.should contain(@article2.subject)
    end
  end

  it "should count articles" do
    rendered.should have_selector("p.article_count") do |p|
      p.should contain(/2\s+articles/)
    end
  end
end
