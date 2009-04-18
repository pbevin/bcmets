require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/post" do
  it "should have fields" do
    assigns[:article] = Article.make
    render 'archive/post'
    response.should have_tag("form#post_form")
    response.should have_tag("input[name=?]", "article[name]")
    response.should have_tag("input[name=?]", "article[email]")
    response.should have_tag("input[name=?]", "article[subject]")
    response.should have_tag("textarea[name=?]", "article[body]")
  end
  
  it "should have extra fields when acting as reply" do
    @article = Article.make
    @reply = @article.reply
    assigns[:article] = @reply
    render 'archive/post'
    response.should have_tag("input[name=?]", "article[to]")
    response.should have_tag("input[name=?]", "article[parent_id]")
    response.should have_tag("input[name=?]", "article[parent_msgid]")
  end
end
