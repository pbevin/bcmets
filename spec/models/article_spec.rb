require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  before(:each) do
    @valid_attributes = {
      :sent_at => Time.now,
      :received_at => Time.now,
      :name => "Pete Bevin",
      :email => "pete@petebevin.com",
      :subject => "Test Article",
      :body => "This is the article body.\n\nPete.\n",
      :msgid => "<xyzzy@petebevin.com>",
      :parent_msgid => nil,
      :parent_id => nil
    }
  end

  it "should create a new instance given valid attributes" do
    Article.create!(@valid_attributes)
  end
  
end

describe Article, ".from_headers" do
  before(:each) do
    text = File.read(File.dirname(__FILE__) + "/../fixtures/article.txt")
    @article = Article.parse(text)
  end
  
  it "should set the received_at time from the first line" do
    @article.received_at.utc.to_s(:db).should eql("2009-03-13 01:33:32")
  end
  
  it "should set the sent date from the Date: header" do
    @article.sent_at.utc.to_s(:db).should eql("2009-03-13 01:33:26")
  end
  
  it "should set the name and email from the From: line" do
    @article.name.should eql("Pete Bevin")
    @article.email.should eql("pete@petebevin.com")
  end
  
  it "should set the subject from the subject line" do
    @article.subject.should eql("[bcmets] Re: Confidentiality &amp; bcmets.org")
  end

  it "should set the body" do
    @article.body.should match(/^Stephanie writes:/m)
    @article.body.should match(/Pete.$/s)
  end
  
  it "should set the message ID" do
    @article.msgid.should eql("<20090313013326.5C4251F30EF@feste.bestiary.com>")
  end

  it "should set the parent message ID (from In-Reply-To:)" do
    @article.parent_msgid.should eql("<20090311232013.12AD51F317D@feste.bestiary.com>")
  end
end

describe Article, "parsing edge cases" do
  def parse(partial)
    text = "From bcmets-bounces@bcmets.org  Thu Mar 12 21:33:32 2009\n" + partial + "\n\nbody\n"
    Article.parse(text)
  end
  
  it "should set name to email if only email is given" do
    article = parse("From: pete@petebevin.com")
    article.name.should eql('pete@petebevin.com')
    article.email.should eql('pete@petebevin.com')
  end
  
  it "should strip angle brackets out of a lone email" do
    article = parse("From: <pete@petebevin.com>")
    article.name.should eql('pete@petebevin.com')
    article.email.should eql('pete@petebevin.com')
  end
  
  it "should parse From lines reasonably" do
    Article.parse_from_line("From bcmets-bounces@bcmets.org  Sun Mar  1 02:15:40 2009").should \
      eql("Sun Mar  1 02:15:40 2009")
  end

  it "should recognize case variants of Message-Id:" do
    parse("Message-ID: xxx").msgid.should eql("xxx")
    parse("Message-id: yyy").msgid.should eql("yyy")
  end
  
  it "should not allow parent_msgid = <>"
  it "should keep track of References: field while unresolved"
end

describe Article, ".link_threads" do
  it "should link articles together based on parent_msgid" do
    art1 = Article.create(:msgid => "<abc>")
    art2 = Article.create(:msgid => "<def>", :parent_msgid => "<abc>")
    
    Article.link_threads
    
    art2.reload
    art2.parent_id.should eql(art1.id)
  end
  
  
end  
  
  
  
  
  
  
  
  
  