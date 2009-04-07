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
  
  it "should set name to email if only email is given" do
    name, email = Article.parse_sender('pete@petebevin.com')
    name.should eql('pete@petebevin.com')
    email.should eql('pete@petebevin.com')
  end
  
  it "should strip angle brackets out of lone email" do
    name, email = Article.parse_sender('<pete@petebevin.com>')
    name.should eql('pete@petebevin.com')
    email.should eql('pete@petebevin.com')
  end    
end