require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  before(:each) do
    @article = Article.make
  end

  it "enforces msgid uniqueness" do
    duplicate = Article.new(:msgid => @article.msgid)
    duplicate.should_not be_valid
  end
  
  it "has a definition of 'recent'" do
    @article.received_at = 1.day.ago
    @article.should be_recent
    
    @article.received_at = 3.months.ago
    @article.should_not be_recent
  end
  
  it "can have a legacy ID" do
    id = "2009-04/0479"
    @article.legacy_id = id
    @article.save
    Article.find_by_legacy_id(id).should == @article
  end

  describe "validation" do
    it "requires a full email address" do
      @article.email = "invalid"
      @article.should_not be_valid
    end
  end
  
  describe ".from_headers" do
    before(:each) do
      text = File.read(File.dirname(__FILE__) + "/../fixtures/article.txt")
      @article = Article.parse(text)
    end

    it "sets the received_at time from the first line" do
      @article.received_at.utc.to_s(:db).should eql("2009-03-13 01:33:32")
    end

    it "sets the sent date from the Date: header" do
      @article.sent_at.utc.to_s(:db).should eql("2009-03-13 01:33:26")
    end

    it "sets the name and email from the From: line" do
      @article.name.should eql("Pete Bevin")
      @article.email.should eql("pete@petebevin.com")
    end

    it "sets the subject from the subject line" do
      @article.subject.should eql("Re: Confidentiality &amp; bcmets.org")
    end

    it "sets the body" do
      @article.body.should match(/^Stephanie writes:/m)
      @article.body.should match(/Pete.$/s)
    end

    it "sets the message ID" do
      @article.msgid.should eql("<20090313013326.5C4251F30EF@feste.bestiary.com>")
    end

    it "sets the parent message ID (from In-Reply-To:)" do
      @article.parent_msgid.should eql("<20090311232013.12AD51F317D@feste.bestiary.com>")
    end
  end

  describe "parsing edge cases" do
    def parse(partial)
      text = "From bcmets-bounces@bcmets.org  Thu Mar 12 21:33:32 2009\n" + partial + "\n\nbody\n"
      Article.parse(text)
    end

    it "sets name to email if only email is given" do
      article = parse("From: pete@petebevin.com")
      article.name.should eql('pete@petebevin.com')
      article.email.should eql('pete@petebevin.com')
    end

    it "strips angle brackets out of a lone email" do
      article = parse("From: <pete@petebevin.com>")
      article.name.should eql('pete@petebevin.com')
      article.email.should eql('pete@petebevin.com')
    end

    it "parses From lines reasonably" do
      Article.parse_from_line("From bcmets-bounces@bcmets.org  Sun Mar  1 02:15:40 2009").should \
        eql("Sun Mar  1 02:15:40 2009")
    end

    it "recognizes case variants of Message-Id:" do
      parse("Message-ID: xxx").msgid.should eql("xxx")
      parse("Message-id: yyy").msgid.should eql("yyy")
    end

    it "does not allow parent_msgid = <>" do
      parse("In-Reply-To: <>").parent_msgid.should be_nil
    end

    it "strips [...] from the subject line" do
      parse("Subject: [bcmets] Grommets").subject.should == "Grommets"
      parse("Subject: Re: [bcmets] Grommets").subject.should == "Re: Grommets"
    end

    it "can reconstruct the From line" do
      parse("From: Pete Bevin <pete@petebevin.com>").from.should == "Pete Bevin <pete@petebevin.com>"
      parse("From: pete@petebevin.com").from.should == "pete@petebevin.com"
    end
  end

  describe ".link_threads" do
    it "links articles together based on parent_msgid" do
      art1 = Article.make(:msgid => "<abc>")
      art2 = Article.make(:msgid => "<def>", :parent_msgid => "<abc>")

      Article.link_threads

      art2.reload
      art2.parent_id.should eql(art1.id)
    end
  end  

  describe ".thread_tree" do
    before(:each) do
      @art1 = Article.make()
      @art2 = Article.make(:parent_id => @art1.id)
      @art3 = Article.make(:parent_id => @art2.id)
      @art4 = Article.make(:parent_id => @art1.id)
      @art5 = Article.make()

      @tree = Article.thread_tree([@art1, @art2, @art3, @art4, @art5])
    end

    it "returns all unparented articles" do
      @tree.count.should == 2
    end

    it "finds children members" do
      @art1.children.map(&:id).should == [@art2.id, @art4.id]
      @art1.children.should == [@art2, @art4]
      @art5.children.should be_nil  # not sure - maybe should be []
      @art2.children.should == [@art3]
    end
    
    it "can iterate over all the children" do
      children = []
      @art1.each_child { |child| children << child }
      children.should == [@art2, @art3, @art4]
    end
  end

  describe ".reply" do
    before(:each) do
      @article = Article.make
    end

    it "returns a reply" do
      @article.should_not be_reply
      @article.reply.should be_reply
    end

    it "adds Re: to the subject line" do
      @article.reply.subject.should == "Re: #{@article.subject}"
    end

    it "doesn't add Re: if the subject line already has it" do
      @article.subject = "Re: grommet welding"
      @article.reply.subject.should == @article.subject
    end

    it "sets the To: field" do
      @article.reply.to.should == @article.from
    end

    it "sets the parent_id and parent_msgid fields" do
      @article.reply.parent_id.should == @article.id
      @article.reply.parent_msgid.should == @article.msgid
    end

    it "quotes the original text" do
      @article.body = "I\nlike\ncheese\n"
      @article.name = "Pete Bevin"
      @article.reply.body.should == "Pete Bevin writes:\n> I\n> like\n> cheese\n"
    end

    it "wraps long lines when quoting" do
      @article.body = (["asdf"] * 100).join(' ')
      @article.reply.body.lines.count.should > 5
      @article.reply.body.lines.find_all {/^> /}.count.should > 5
    end

    it "sets mail_to and mail_cc based on reply_type" do
      $list_address = 'list@example.com'

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

  describe "bugs" do
    it "can show articles from December" do
      Article.for_month(2006, 12).should_not be_nil
    end

    it "figure out mail_to and mail_cc" do
      params = {
        "name"=>"Pete Bevin",
        "body"=>"xxx",
        "to"=>"Pete Bevin <pete@petebevin.com>",
        "subject"=>"Re: Thingummy",
        "parent_id"=>"5282",
        "parent_msgid"=>"<c5e58b18c735b668@bcmets.org>",
        "reply_type"=>"list",
        "email"=>"pete@petebevin.com"
      }
      $list_address = 'list@example.com'
      @article = Article.new(params)

      @article.mail_to.should == 'list@example.com'
    end
  end

  describe Article, "conversation handling" do
    describe "on creation" do
      it "creates a new conversation for a new article" do
        article = Article.make
        article.conversation.should_not be_nil
        article.conversation.articles.should == [article]
      end

      it "adds a reply to its parent's conversation" do
        article = Article.make
        reply = article.reply
        reply.name = Faker::Name.name
        reply.email = Faker::Internet.email
        reply.save!
        article.conversation.should == reply.conversation
        article.conversation.articles.should == [article, reply]
      end

      it "relies on parent_id, not just parent, for conversation handling" do
        article = Article.make
        params = {
          "name"=>"Pete Bevin",
          "email" => "pete@petebevin.com",
          "body"=>"xxx",
          "to" => article.from,
          "subject" => article.reply.subject,
          "parent_id" => article.id,
          "parent_msgid" => article.msgid,
          "reply_type" => "list"
        }
        reply = Article.new(params)
        reply.save!
        article.conversation.should == reply.conversation
      end
    end

    describe "link_threads()" do  
      it "links up conversations" do
        a1 = Article.make
        a2 = Article.make(:parent_msgid => a1.msgid)
        Article.link_threads
        a1.reload.conversation.should === a1.reload.conversation
      end

      it "handles out of order message arrival" do
        a1 = Article.make(:msgid => "3", :parent_msgid => "2")
        Article.link_threads

        a2 = Article.make(:msgid => "2", :parent_msgid => "1")
        Article.link_threads

        a3 = Article.make(:msgid => "1")
        Article.link_threads

        a1.reload
        a2.reload
        a3.reload

        a1.conversation.should === a2.conversation
      end
    end
  end
end

