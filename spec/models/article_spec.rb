# Encoding: utf8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Article do
  before(:each) do
    @attrs = {
      :name => "Fred",
      :email => "fred@example.com",
      :body => "lorem ipsum",
      :subject => "my title",
      :msgid => "12345@bcmets.org"
    }
    @article = Article.new(@attrs)
  end

  it "recognizes valid attributes" do
    Article.new(@attrs).should be_valid
  end

  it "enforces msgid uniqueness" do
    lambda {
      Article.create(@attrs)
      Article.create(@attrs)
    }.should change(Article, :count).by(1)
  end

  it "has a definition of 'recent'" do
    @article.received_at = 1.day.ago
    @article.should be_recent

    @article.received_at = 3.months.ago
    @article.should_not be_recent
  end

  it "requires a full email address" do
    @article.email = "invalid"
    @article.should_not be_valid
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
      @article.reply.body.lines.find_all { %r{^> } }.count.should > 5
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

  it "detects charset based on content type" do
    Article.new(
      :content_type => 'text/plain; charset=utf-8'
    ).charset.should == "utf-8"

    Article.new(
      :content_type => 'text/plain; charset="us-ascii" ; format="flowed"'
    ).charset.should == "us-ascii"

    Article.new(:content_type => nil).charset.should == "utf-8"
    Article.new(:content_type => "").charset.should == "utf-8"
  end

  describe '#body_utf8' do
    it "converts body to UTF8 when content type is UTF8" do
      Article.new(
        :content_type => 'text/plain; charset=utf-8',
        :body => "Påté"
      ).body_utf8.should ==
        "Påté"
    end

    it "converts ISO-8859-1 to UTF8" do
      Article.new(
        :content_type => 'text/plain;charset="iso8859-1"',
        :body => "sch\366n"
      ).body_utf8.should ==
        "sch\303\266n"
    end

    it "converts CP1252 to UTF8 when normal conversion fails" do
      Article.new(
        :content_type => 'text/plain',
        :body => "\240Dear all,"
      ).body_utf8.should ==
        "\302\240Dear all,"
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
        a1.reload.conversation.should === a2.reload.conversation
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

