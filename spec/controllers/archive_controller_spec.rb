require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Enumerable
  def consecutive_pairs
    first = true
    prev = nil
    each do |e|
      unless first
        yield prev, e
      end
      first = false
      prev = e
    end
  end
end


describe ArchiveController do
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
    
    it "should assign year" do
      get 'index'
      assigns(:year).should == Time.now.year
      assigns(:month).should == Time.now.month
    end
    
    it "should allow search engines" do
      get 'index'
      assigns(:indexable).should == true
    end
  end

  describe "GET 'month' ordering" do
    before(:each) do
      Article.make(:subject => "3", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:33:00 -0400 (EDT)"))
      Article.make(:subject => "2", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:32:00 -0400 (EDT)"))
      Article.make(:subject => "4", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:34:00 -0400 (EDT)"))
      Article.make(:subject => "1", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:31:00 -0400 (EDT)"))
      get 'month', :year => '2009', :month => '3'
    end
    
    it "should be successful" do
      response.should be_success
    end
    
    it "should set the articles list" do
      assigns(:articles).count.should == 4
    end
    
    it "should set the article count" do
      assigns(:article_count).should == 4
    end

    # TODO: This is really a test on the model
    it "should list articles in reverse order" do
      articles = assigns(:articles)
      articles.consecutive_pairs do |a, b|
        a.received_at.should > b.received_at
      end
    end
    
    it "does not allow search engines" do
      assigns(:indexable).should == false
    end
  end
  
  describe "GET month" do
    it "should recognize @year and @month" do
      Article.should_receive(:for_month).once().with(2006, 5).and_return([])
      get 'month', :year => '2006', :month => '05'
    end

    it "should recognize @old_year_month" do
      Article.should_receive(:for_month).once().with(2006, 5).and_return([])
      get 'month', :old_year_month => '2006-05'
    end
  end

  describe "GET this_month" do
    it "should redirect" do
      get 'this_month'
      response.should be_redirect
    end
  end
  
  describe "GET old_article" do
    it "should redirect" do
      article = Article.new
      article.id = 666
      Article.should_receive(:find_by_legacy_id).once().with('2009-04/0179').and_return(article)
      
      get 'old_article', :old_year_month => '2009-04', :article_number => '0179'
      response.should redirect_to(
        :controller => "archive",
        :action => "article",
        :id => article.id)
    end
    
    it "should handle not-found bookmarks gracefully" do
      Article.should_receive(:find_by_legacy_id).and_return(nil)
      
      get 'old_article', :old_year_month => '2009-04', :article_number => '0666'
      response.should redirect_to(:controller => "archive", :action => "index")
      flash[:notice].should =~ /bookmark/
    end

    it "supports /archive/article/:id in place of /article/:id" do
      article = Article.make
      get 'article', :id => article.id
        response.should redirect_to(:controller => "articles", :action => "show", :id => article.id)
    end
  end
      
  
  describe "GET month_by_date" do
    it "should list articles in reverse date order" do
      article1 = Article.make(:received_at => DateTime.parse("Thu, 12 Mar 2009 21:33:00 -0400 (EDT)"))
      article2 = Article.make(:received_at => DateTime.parse("Fri, 13 Mar 2009 21:33:00 -0400 (EDT)"))
      article3 = Article.make(:received_at => DateTime.parse("Fri, 13 Mar 2009 22:46:00 -0400 (EDT)"))
      get 'month_by_date', :year => '2009', :month => '3'
      
      thu = Date.new(2009, 3, 12)
      fri = Date.new(2009, 3, 13)

      assigns(:dates).should == [fri, thu]      
      assigns(:articles).should == { fri => [article3, article2], thu => [article1] }
      assigns(:article_count).should == 3
    end
  end
end
