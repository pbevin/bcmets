require 'spec_helper'

describe "archive/month" do
  before(:each) do
    @art1 = Article.make!(sent_at: DateTime.parse("2009-03-28 13:00:00"))
    @art2 = Article.make!(sent_at: DateTime.parse("2009-03-29 04:00:00"), parent_id: @art1.id)

    assign :year, "2009"
    assign :month, "3"
    assign :articles, [@art1, @art2]

    render
  end

  it "should show articles" do
    rendered.should have_selector("a.subject") do |a|
      a.map(&:text).should == [
        @art1.subject,
        @art2.subject
      ]
    end
  end

  it "should link to by_date view" do
    rendered.should have_selector("a.date_order") do |a|
      a.attr("href").value.
        should == '/archive/2009/3/date'
    end
  end
end
