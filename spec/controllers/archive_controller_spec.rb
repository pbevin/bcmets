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
      Article.stub!(:send_via_smtp)
      @article = Article.make_unsaved :msgid => nil      
    end

    def do_post
      post 'post', :article => {
        :name => @article.name,
        :email => @article.email,
        :subject => @article.subject,
        :qt => @article.body 
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
    before(:each) do
      cookies[:name] = 'My Name'
      cookies[:email] = 'my.email@example.com'
      article = Article.make
      @reply = article.reply
      get 'reply', :id => article.id

      @article = assigns[:article]
    end

    it "should present fields based on Article.reply" do
      @article.subject.should == @reply.subject
      @article.to.should == @reply.to
      @article.parent_id.should == @reply.parent_id
      @article.parent_msgid.should == @reply.parent_msgid
    end
    
    it "should default name and email from cookies" do
      @article.name.should == 'My Name'
      @article.email.should == 'my.email@example.com'
    end
  end
  
  describe "POST 'reply'" do
    def do_post(reply_type = 'list')
      @article = Article.make
      @reply = @article.reply
      @reply.name = 'My Name'
      @reply.email = 'my.email@example.com'
      Article.should_receive(:send_via_smtp).once().with(anything(), @reply.email, kind_of(Array))
      post 'post', :id => @article.id, :article => {
        :name => @reply.name,
        :email => @reply.email,
        :reply_type => reply_type,
        :to => @reply.to,
        :parent_id => @reply.parent_id,
        :parent_msgid => @reply.parent_msgid,
        :subject => @reply.subject,
        :qt => @reply.body 
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
  
  describe "Post 'reply' bugs" do
    it "should let Cathy in L.A. post" do
      params = {
        "article"=> {
            :name => "Cathy in L. A.",  # final period causes problems unless quoted
            :email => "ogpanfilo2@aol.com",
            :subject => "Re: Re: New look for bcmets",
            :qt => "xxxx"
        },
        "commit"=>"Post",
        "authenticity_token"=>"CzuSHm/qCOy+af5uAYEUDAFD5W/MteGNpr58sIi87Pk="
      }
      
      Article.should_receive(:send_via_smtp).with(anything(), "ogpanfilo2@aol.com", anything())
      post 'post', params
    end
  end
  
  describe "Spam prevention" do
    it "should reject spam" do
      params = {
        "article"=> {
            :name => "Buy Viagra!",
            :email => "buy@viagra.example.com", 
            :subject => "Viagra spam",
            :body => "oops, fell into the spam trap"
        },
        "commit"=>"Post"
      }
      
      Article.should_not_receive(:send_via_smtp)
      lambda { post 'post', params }.should_not change { Article.count }
      response.should redirect_to(:controller => "archive", :action => "index")
      flash[:notice].should == "Message sent."
    end
    
    it "should accept ham" do
      params = {
        :article => {
          :name => "Fred",
          :email => "fred@example.com",
          :subject => "Subject",
          :body => "",
          :qt => "xxxx"
        }
      }
      Article.should_receive(:send_via_smtp)
      post 'post', params
    end
    
    it "should clear body field when fields have errors" do
      params = {
        :article => {
          :name => "",
          :email => "",
          :subject => "",
          :qt => "body"
        }
      }
      post 'post', params
      assigns[:article].body.should be_nil
      assigns[:article].qt.should == "body"
    end
    
    it "should assign qt, not body, on reply" do
      article = Article.make
      get 'reply', { :id => article.id }
      assigns(:article).body.should be_nil
      assigns(:article).qt.should == article.reply.body
    end
  end
end
