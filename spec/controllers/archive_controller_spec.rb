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
  describe "GET 'month' ordering" do
    before(:each) do
      Article.make!(:subject => "3", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:33:00 -0400 (EDT)"))
      Article.make!(:subject => "2", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:32:00 -0400 (EDT)"))
      Article.make!(:subject => "4", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:34:00 -0400 (EDT)"))
      Article.make!(:subject => "1", :received_at => DateTime.parse("Thu, 12 Mar 2009 21:31:00 -0400 (EDT)"))
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
  end

  describe "GET this_month" do
    it "should redirect to the current month" do
      Time.zone.should_receive(:today).and_return(Date.new(2009, 11, 15))
      get 'this_month'
      response.should redirect_to(archive_month_url(:year => '2009', :month => '11'))
    end
  end

  describe "GET month_by_date" do
    it "should list articles in reverse date order" do
      article1 = Article.make!(:received_at => DateTime.parse("Thu, 12 Mar 2009 12:33:00 -0400 (EDT)"))
      article2 = Article.make!(:received_at => DateTime.parse("Fri, 13 Mar 2009 12:33:00 -0400 (EDT)"))
      article3 = Article.make!(:received_at => DateTime.parse("Fri, 13 Mar 2009 13:46:00 -0400 (EDT)"))
      get 'month_by_date', :year => '2009', :month => '3'

      thu = Date.new(2009, 3, 12)
      fri = Date.new(2009, 3, 13)

      assigns(:dates).should == [fri, thu]
      assigns(:articles).should == { fri => [article3, article2], thu => [article1] }
      assigns(:article_count).should == 3
    end
  end
end
