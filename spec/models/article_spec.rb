# Encoding: UTF-8

require 'rails_helper'

describe Article, type: :model do
  before(:each) do
    @attrs = {
      name: "Fred",
      email: "fred@example.com",
      body: "lorem ipsum",
      subject: "my title",
      msgid: "12345@bcmets.org"
    }
    @article = Article.new(@attrs)
  end

  it "recognizes valid attributes" do
    Article.new(@attrs).should be_valid
  end

  it "enforces msgid uniqueness" do
    lambda do
      Article.create(@attrs)
      Article.create(@attrs)
    end.should change(Article, :count).by(1)
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

  describe ".thread_tree" do
    before(:each) do
      @art1 = Article.make!
      @art2 = Article.make!(parent_id: @art1.id)
      @art3 = Article.make!(parent_id: @art2.id)
      @art4 = Article.make!(parent_id: @art1.id)
      @art5 = Article.make!

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

  describe '#parse' do
    it "copes with multi-line headers" do
      text = <<'.'
From name@example.com Thu 10 Dec 2015 13:45:20 +0000
From: Test <test@example.com>
Date: Thu 10 Dec 2015 13:25:06 +0000
Message-ID: <1234@example.com>
Subject: [bcmets] This is a very
  long subject line

body
.
      article = Article.parse(text)
      expect(article).to have_attributes(
        msgid: "<1234@example.com>",
        subject: "This is a very long subject line",
        name: "Test",
        email: "test@example.com",
        body: "body\n"
      )


    end
  end

  describe ".reply" do
    before(:each) do
      @article = Article.make!
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

    it "sets the parent_id field" do
      @article.reply.parent_id.should == @article.id
    end

#     it "sets mail_to and mail_cc based on reply_type" do
#       Rails.configuration.list_address = 'list@example.com'

#       @article.reply_type = 'list'
#       @article.reply.mail_to.should == 'list@example.com'
#       @article.reply.mail_cc.should == ''

#       @article.reply_type = 'sender'
#       @article.reply.mail_to.should == @article.from
#       @article.reply.mail_cc.should == ''

#       @article.reply_type = 'both'
#       @article.reply.mail_to.should == 'list@example.com'
#       @article.reply.mail_cc.should == @article.from
#     end
  end

  it "detects charset based on content type" do
    Article.new(
      content_type: 'text/plain; charset=utf-8'
    ).charset.should == "utf-8"

    Article.new(
      content_type: 'text/plain; charset="us-ascii" ; format="flowed"'
    ).charset.should == "us-ascii"

    Article.new(
      content_type: 'text/plain; charset=SOME-CHARSET; format=flowed'
    ).charset.should == "SOME-CHARSET"

    Article.new(content_type: nil).charset.should == "utf-8"
    Article.new(content_type: "").charset.should == "utf-8"
  end

  describe '#body_utf8' do
    it "converts body to UTF8 when content type is UTF8" do
      Article.new(
        content_type: 'text/plain; charset=utf-8',
        body: "Påté"
      ).body_utf8.should ==
        "Påté"
    end

    it "converts ISO-8859-1 to UTF8" do
      schön_iso_8859_1 = [115, 99, 104, 246, 110].pack("C*").force_encoding("US-ASCII")
      body = Article.new(
        content_type: 'text/plain;charset="iso8859-1"',
        body: schön_iso_8859_1
      ).body_utf8
      # body.should == "schön"
      body.encoding.name.should == "UTF-8"
      body.bytes.to_a.should == [115, 99, 104, 195, 182, 110]
    end

    it "converts CP1252 to UTF8 when normal conversion fails" do
      # Character 160 is non-breaking space in CP1252,
      # which is 0xC2 0xA0 in UTF-8
      inbytes = [160] + "Hi,".bytes.to_a
      body = Article.new(
        content_type: 'text/plain',
        body: inbytes.pack("C*")
      ).body_utf8
      body.encoding.name.should == "UTF-8"
      body.bytes.to_a.should == [0xC2, 0xA0] + "Hi,".bytes.to_a
    end
  end

  describe 'send_via_email' do
    let(:article) do
      Article.new
    end

    it "does not escape the body" do
      article.body = "It's working!"
      article.send_via_email
      ActionMailer::Base.deliveries.last.body.to_s.strip
        .should == article.body
    end
  end

  describe "bugs" do
    it "can show articles from December" do
      Article.for_month(2006, 12).should_not be_nil
    end

    it "figure out mail_to and mail_cc" do
      params = {
        "name" => "Pete Bevin",
        "body" => "xxx",
        "to" => "Pete Bevin <pete@petebevin.com>",
        "subject" => "Re: Thingummy",
        "parent_id" => "5282",
        "parent_msgid" => "<c5e58b18c735b668@bcmets.org>",
        "reply_type" => "list",
        "email" => "pete@petebevin.com"
      }
      Rails.configuration.list_address = 'list@example.com'
      @article = Article.new(params)

      @article.mail_to.should == 'list@example.com'
    end
  end

  describe Article, "conversation handling" do
    describe "on creation" do
      it "creates a new conversation for a new article" do
        article = Article.make!
        article.conversation.should_not be_nil
        article.conversation.articles.should == [article]
      end

      it "adds a reply to its parent's conversation" do
        parent = Article.make!(msgid: "<abc@example.com>")

        reply = Article.new
        reply.msgid = "<xyz@example.com>"
        reply.parent_msgid = parent.msgid
        reply.name = Faker::Name.name
        reply.email = Faker::Internet.email
        reply.subject = "Reply"
        reply.body = "yadda yadda yadda"
        reply.save!

        expect(parent.conversation).to eq(reply.conversation)
        expect(reply.conversation.articles).to contain_exactly(parent, reply)
      end

      it "can handle a reply that appears before the parent" do
        reply = Article.new
        reply.msgid = "<xyz@example.com>"
        reply.parent_msgid = "<abc@example.com>"
        reply.name = Faker::Name.name
        reply.email = Faker::Internet.email
        reply.subject = "Reply"
        reply.body = "yadda yadda yadda"
        reply.save!

        expect(reply.conversation.articles).to contain_exactly(reply)
      end
    end

    specify "body has non-UTF8 characters" do
      # The mail gem's parser chokes on messages where
      # the body has, for example, \xa0 characters, so
      # we revert to ArticleParser in those cases.
      text = [
        "From name@example.com Thu 10 Dec 2015 13:45:20 +0000",
        "From: Test <test@example.com>",
        "Date: Thu 10 Dec 2015 13:25:06 +0000",
        "Message-ID: <1234@example.com>",
        "Subject: test",
        "",
        "body\xa0with latin-1 characters"
      ]
      article = Article.parse(text.join("\n"))
      expect(article).to have_attributes(
        subject: "test",
        body: "body\u{a0}with latin-1 characters\n"
      )
    end
  end

  describe '#sent_at_human' do
    it "shows a recent date as just the time" do
      Timecop.freeze("2012-07-01 11:39:00".to_time) do
        a = Article.new(sent_at: "2012-07-01 09:41:18")
        a.sent_at_human.should == "09:41 AM"
      end
    end

    it "shows a date from yesterday as just the date" do
      Timecop.freeze("2012-07-01 11:39:00".to_time) do
        a = Article.new(sent_at: "2012-06-30 23:52:39")
        a.sent_at_human.should == "Jun 30, 2012"
      end
    end
  end
end
