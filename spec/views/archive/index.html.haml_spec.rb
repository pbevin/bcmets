require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "archive/index" do
  before(:each) do
    assign(:year, 2009)
    assign(:month, 3)
    render
  end

  it "should render years back to 2001" do
    (2000..2009).each do |year|
      rendered.should have_selector('h2', text: year.to_s)
    end
  end

  it "should have links for every month" do
    (2001..2008).each do |year|
      rendered.should have_selector("td>a:contains('March #{year}')")
      rendered.should have_selector("td>a:contains('June #{year}')")
      rendered.should have_selector("td>a:contains('September #{year}')")
      rendered.should have_selector("td>a:contains('December #{year}')")
    end
  end

  it "should highlight the current month" do
    rendered.should have_selector("td>a>strong:contains('March 2009')")
  end

  it "should not link future months" do
    rendered.should have_selector("td:contains('April 2009')")
    rendered.should_not have_selector("td>a:contains('April 2009')")
  end

  it "should not render Jan 2000 as a link since it has no articles" do
    rendered.should have_selector("td>a:contains('January 2001')")
    rendered.should have_selector("td:contains('January 2000')")
    rendered.should_not have_selector("td>a:contains('January 2000')")
  end

  it "should link to /post, not /post.pl" do
    rendered.should have_selector("a[href='/post']")
  end
end
