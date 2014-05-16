require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArchiveController, "route generation" do
  it "is shown by default" do
    { get: "/" }.should route_to(controller: "archive", action: "index")
  end

  it "responds to /archive" do
    { get: "/archive" }.should route_to(controller: "archive", action: "index")
  end

  it "responds to /archive/:year/:month" do
    { get: "/archive/2009/3" }.
      should route_to(
        controller: "archive",
        action: "month",
        year: "2009",
        month: "3"
      )
  end

  it "responds to /archive/:article_id" do
    # Important for bookmarked articles
    { get: "/archive/article/14" }.
      should route_to(
        controller: "archive",
        action: "article",
        id: "14"
      )
  end

  it "recognizes the old post.pl URL" do
    { get: "/post.pl" }.
      should route_to(
        controller: "articles",
        action: "new"
      )
  end

  it "recognizes an old month URL" do
    { get: "/archive/2006-05" }.
      should route_to(
        controller: "archive",
        action: "month",
        old_year_month: "2006-05"
      )
  end

  it "routes /donate the way I like" do
    { get: "/donate" }.
      should route_to(
        controller: "pages",
        action: "donate"
      )
  end

  it "figures out a legacy URL" do
    { get: "/archive/2009-04/0179.html" }.
      should route_to(
        controller: "archive",
        action: "old_article",
        old_year_month: "2009-04",
        article_number: "0179"
      )
  end
end
