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

  #Delete these examples and add some real ones
  it "should use ArchiveController" do
    controller.should be_an_instance_of(ArchiveController)
  end


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
    # TODO it "should include articles that are part of current threads"
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
  
  describe "GET 'article'" do
    before(:each) do
      @article = Article.create(:body => "body")
      get 'article', :id => @article.id
    end

    it "should be successful" do
      response.should be_success
    end
    
    it "should assign @article" do
      assigns(:article).should == @article
    end
    
    it "should have a title" do
      assigns(:title).should == @article.subject
    end
  end
end
