require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  before(:each) do
    @article = Article.make
  end

  it "should be unique by msgid" do
    duplicate = Article.new(:msgid => @article.msgid)
    duplicate.should_not be_valid
  end
  
  it "should know what recent means" do
    @article.received_at = 1.day.ago
    @article.should be_recent
    
    @article.received_at = 3.months.ago
    @article.should_not be_recent
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
    @article.subject.should eql("Re: Confidentiality &amp; bcmets.org")
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
  
  it "should not allow parent_msgid = <>" do
    parse("In-Reply-To: <>").parent_msgid.should be_nil
  end
  
  it "should strip [...] from the subject line" do
    parse("Subject: [bcmets] Grommets").subject.should == "Grommets"
    parse("Subject: Re: [bcmets] Grommets").subject.should == "Re: Grommets"
  end
  
  it "can reconstruct the From line" do
    parse("From: Pete Bevin <pete@petebevin.com>").from.should == "Pete Bevin <pete@petebevin.com>"
    parse("From: pete@petebevin.com").from.should == "pete@petebevin.com"
  end
end

describe Article, ".link_threads" do
  it "should link articles together based on parent_msgid" do
    art1 = Article.make(:msgid => "<abc>")
    art2 = Article.make(:msgid => "<def>", :parent_msgid => "<abc>")
    
    Article.link_threads
    
    art2.reload
    art2.parent_id.should eql(art1.id)
  end
end  

describe Article, ".thread_tree" do
  before(:each) do
    @art1 = Article.make()
    @art2 = Article.make(:parent_id => @art1.id)
    @art3 = Article.make(:parent_id => @art2.id)
    @art4 = Article.make(:parent_id => @art1.id)
    @art5 = Article.make()
    
    @tree = Article.thread_tree([@art1, @art2, @art3, @art4, @art5])
  end
  
  it "should return all unparented articles" do
    @tree.count.should == 2
  end
  
  it "should set children members" do
    @art1.children.map(&:id).should == [@art2.id, @art4.id]
    @art1.children.should == [@art2, @art4]
    @art5.children.should be_nil  # not sure - maybe should be []
    @art2.children.should == [@art3]
  end
end 
  
describe Article, ".reply" do
  before(:each) do
    @article = Article.make
  end
  
  it "should be a reply" do
    @article.should_not be_reply
    @article.reply.should be_reply
  end
  
  it "should Re: the subject line" do
    @article.reply.subject.should == "Re: #{@article.subject}"
  end

  it "should not add Re: if the subject line already has it" do
    @article.subject = "Re: grommet welding"
    @article.reply.subject.should == @article.subject
  end

  it "should set the To: field" do
    @article.reply.to.should == @article.from
  end
  
  it "should set the parent_id and parent_msgid fields" do
    @article.reply.parent_id.should == @article.id
    @article.reply.parent_msgid.should == @article.msgid
  end
  
  it "should quote the original text" do
    @article.body = "I\nlike\ncheese\n"
    @article.name = "Pete Bevin"
    @article.reply.body.should == "Pete Bevin writes:\n> I\n> like\n> cheese\n"
  end

  it "should wrap long lines when quoting" do
    @article.body = (["asdf"] * 100).join(' ')
    @article.reply.body.lines.count.should > 5
  end
  
  it "should set mail_to and mail_cc based on reply_type" do
    Article.list_address = 'list@example.com'
    
    @article.reply_type = 'list'
    @article.reply.mail_to.should == 'list@example.com'
    @article.reply.mail_cc.should == ''
    
    @article.reply_type = 'sender'
    @article.reply.mail_to.should == @article.from
    @article.reply.mail_cc.should == ''
    
    @article.reply_type = 'both'
    @article.reply.mail_to.should == 'list@example.com'
    @article.reply.mail_cc.should == @article.from
  end
end

describe Article, " bugs" do
  it "should be able to get articles from December" do
    Article.for_month(2006, 12).should_not be_nil
  end
end
