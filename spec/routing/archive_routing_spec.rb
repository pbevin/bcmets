require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArchiveController, "route generation" do
  it "is shown by default" do
    params_from(:get, "/").should == { :controller => "archive", :action => "index" }
  end
  
  it "responds to /archive" do
    params_from(:get, "/archive").should == { :controller => "archive", :action => "index" }
  end
  
  it "responds to /archive/:year/:month" do
    params_from(:get, "/archive/2009/3").should == { 
      :controller => "archive", 
      :action => "month", 
      :year => "2009", 
      :month => "3" }
  end
  
  it "responds to /archive/:article_id" do
    params_from(:get, "/archive/article/14").should == { 
      :controller => "archive",
      :action => "article",
      :id => "14" }
  end
  
  it "recognizes some old URLs" do
    params_from(:get, '/post.pl').should == {
      :controller => 'archive',
      :action => 'post'
    }
    
    params_from(:get, '/archive/2006-05').should == {
      :controller => 'archive',
      :action => 'month',
      :old_year_month => '2006-05'
    }
  end

  it "routes /donate the way I like" do
    params_from(:get, "/donate").should == {
      :controller => "pages",
      :action => "donate"
    }
  end
  
  it "figures out legacy URLs" do
    params_from(:get, "/archive/2009-04/0179.html").should == {
      :controller => "archive",
      :action => "old_article",
      :old_year_month => "2009-04",
      :article_number => "0179"
    }
  end
end