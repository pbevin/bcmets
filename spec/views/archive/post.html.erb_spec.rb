require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/post" do
  it "should have fields" do
    render 'archive/post'
    response.should have_tag("form#post_form")
    response.should have_tag("input[name=?]", "article[name]")
    response.should have_tag("input[name=?]", "article[email]")
    response.should have_tag("input[name=?]", "article[subject]")
    response.should have_tag("textarea[name=?]", "article[body]")
  end
end
