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
      @article = Article.make(:body => "body")
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
  
  describe "GET 'post'" do
    it "should have blank fields" do
      get 'post'
      assigns(:article).should be_instance_of(Article)
      assigns(:article).subject.should be_blank
      assigns(:article).body.should be_blank
    end
    
    it "should default to cookies for name and email" do
      cookies[:name] = 'My Name'
      cookies[:email] = 'my.email@example.com'
      get 'post'
      assigns(:article).name.should == 'My Name'
      assigns(:article).email.should == 'my.email@example.com'
    end
  end
  
  describe "POST 'post'" do
    before(:each) do
      controller.stub!(:send_via_email)
      @article = Article.make_unsaved :msgid => nil      
    end

    def do_post
      post 'post', :article => {
        :name => @article.name,
        :email => @article.email,
        :subject => @article.subject,
        :body => @article.body 
      }
      @article = assigns(:article)
    end
    
    it "should send email if all fields are set" do
      controller.should_receive(:send_via_email).once
      do_post
    end
    
    it "should get saved" do
      lambda { do_post }.should change { Article.count }.by(1)
    end
    
    it "should redirect with flash" do
      do_post
      response.should redirect_to(articles_url)
      flash[:notice].should == "Message sent."
    end
    
    it "should initialize fields" do
      do_post
      @article.msgid.should =~ /<[0-9a-f]{16}@bcmets.org>/
      @article.received_at.should == @article.sent_at
      @article.received_at.should > 1.second.ago
      @article.received_at.should < 1.second.from_now
    end
    
    it "should validate fields" do
      @article.email = ""
      controller.should_not_receive(:send_via_email)
      lambda { do_post }.should_not change { Article.count }
    end
    
    it "should set cookies" do
      @article.name = 'Pete Bevin'
      @article.email = 'pete@petebevin.com'
      do_post
      cookies[:name].should == 'Pete+Bevin'
      cookies[:email].should == 'pete%40petebevin.com'
    end
  end
  
  describe "GET 'reply'" do
    it "should present fields based on Article.reply" do
      @article = Article.make
      get 'reply', :id => @article.id
      assigns[:article].attributes.should == @article.reply.attributes
    end
    
    it "should default name and email from cookies" do
      cookies[:name] = 'My Name'
      cookies[:email] = 'my.email@example.com'
      @article = Article.make
      get 'reply', :id => @article.id
      assigns[:article].name.should == 'My Name'
      assigns[:article].email.should == 'my.email@example.com'
    end
  end
  
  describe "POST 'reply'" do
    def do_post(reply_type = 'list')
      controller.stub!(:send_via_email)
      @article = Article.make
      @reply = @article.reply
      @reply.name = 'My Name'
      @reply.email = 'my.email@example.com'
      post 'post', :id => @article.id, :article => {
        :name => @reply.name,
        :email => @reply.email,
        :reply_type => reply_type,
        :to => @reply.to,
        :parent_id => @reply.parent_id,
        :parent_msgid => @reply.parent_msgid,
        :subject => @reply.subject,
        :body => @reply.body 
      }      
    end
    
    it "should redirect back to the original article" do
      do_post
      response.should redirect_to(:controller => 'archive', :action => 'article', :id => @article.id)
    end
    
    it "should not save if reply_type is sender" do
      do_post('sender')
      assigns[:article].should be_new_record
    end
    
    it "should save the article" do
      do_post('list')
      assigns[:article].should_not be_new_record
    end
  end
end
