require 'spec_helper'

describe "Article Parser" do
  attr_accessor :article, :parser

  before(:each) do
    @article = Article.new
    @parser = ArticleParser.new(article)
  end

  it "keeps state based on where it is in the email" do
    parser.state.should == :empty
    parser << "From blah"
    parser.state.should == :header
    parser << "Subject: xyzzy"
    parser.state.should == :header
    parser << ""
    parser.state.should == :body
  end

  it "counts the article body as anything after the first blank line" do
    parser.should_receive(:body).once.with("xyzzy")

    parser << "From blah"
    parser << ""
    parser << "xyzzy"
    parser.save
  end

  it "parses the Subject line" do
    parser.header "Subject: squeamish ossifrage"
    article.subject.should == "squeamish ossifrage"
  end

  it "strips mailing list names from the subject line" do
    parser.header "Subject: Re: [bcmets] Taxol"
    article.subject.should == "Re: Taxol"
  end

  it "sets the received_at field based on the first line" do
    parser << "From bcmets-bounces@bcmets.org  Thu Mar 12 21:33:32 2009"
    article.received_at.should == Time.zone.parse("Thu Mar 12 21:33:32 2009")
  end

  it "is not fooled by two double spaces in dates before the 10th" do
    parser << "From bcmets-bounces@bcmets.org  Thu Mar  5 21:33:32 2009"
    article.received_at.should == Time.zone.parse("Thu Mar  5 21:33:32 2009")
  end

  it "sets the sent_at field based on the Date: header" do
    parser.header "Date: Thu, 12 Mar 2009 21:33:26 -0400 (EDT)"
    article.sent_at.should == Time.gm(2009, 3, 13, 1, 33, 26)
  end

  it "sets the content_type field" do
    parser.header "Content-Type: text/plain"
    article.content_type.should == "text/plain"
  end

  it "parses the Message ID" do
    parser.header "Message-ID: xxx"
    article.msgid.should == "xxx"

    # Common variant
    parser.header "Message-id: yyy"
    article.msgid.should == "yyy"
  end

  it "ignores <> in In-Reply-To" do
    # Some stupid MTA's set In-Reply-To: to <> meaning "nothing" - ignore them
    parser.header "In-Reply-To: <>"
    article.parent_msgid.should be_nil
  end

  context "With In-Reply-To but not References" do
    it "sets the parent message ID" do
      parser.header "In-Reply-To: <xyzzy@bcmets.org>"
      article.parent_msgid.should == "<xyzzy@bcmets.org>"
    end
  end

  context "With References but no In-Reply-To" do
    it "sets the parent message ID" do
      parser.header "References: <xyzzy@bcmets.org>"
      article.parent_msgid.should == "<xyzzy@bcmets.org>"
    end
  end

  context "With a multi-line References: header" do
    it "takes the first message ID as the parent" do
      parser.header "References: <xyzzy@bcmets.org>"
      parser.header " <plugh@bcmets.org>"
      article.parent_msgid.should == "<xyzzy@bcmets.org>"
    end
  end

  context "With both References: and In-Reply-To" do
    it "takes the parent Message ID from In-Reply-To" do
      parser.header "In-Reply-To: <plover@bcmets.org>"
      parser.header "References: <xyzzy@bcmets.org>"
      parser.header " <plugh@bcmets.org>"
      article.parent_msgid.should == "<plover@bcmets.org>"
    end

    it "still works if References: comes first" do
      parser.header "References: <xyzzy@bcmets.org>"
      parser.header " <plugh@bcmets.org>"
      parser.header "In-Reply-To: <plover@bcmets.org>"
      article.parent_msgid.should == "<plover@bcmets.org>"
    end
  end

  it "sets the name and email of the sender" do
    parser.header "From: Mary Jones <mary@example.com>"
    article.name.should == "Mary Jones"
    article.email.should == "mary@example.com"

    parser.header "From: mary@example.com"
    article.name.should == "mary@example.com"
    article.email.should == "mary@example.com"

    parser.header "From: <mary@example.com>"
    article.name.should == "mary@example.com"
    article.email.should == "mary@example.com"
  end

  it "recognizes multi-part lines" do
    parser.header "Subject: a very"
    article.subject.should == "a very"
    parser.header "   long subject line"
    article.subject.should == "a very long subject line"
  end

  describe "Character set parsing" do
    let(:body_iso8859_1) { "Hello, \xA0 world!".force_encoding("binary") }
    let(:body_utf8) { "Hello, \xC2\xA0 world!".force_encoding("binary") }

    it "converts an ISO-8859-1 body to UTF-8" do
      parser.body(body_iso8859_1)
      parser.save
      article.body.strip.should == body_utf8.force_encoding("UTF-8")
    end

    it "leaves a UTF-8 body as-is" do
      parser.body(body_utf8)
      parser.save
      article.body.strip.should == body_utf8.force_encoding("UTF-8")
      article.charset.should == "utf-8"
    end

    it "removes emoji" do
      Article.delete_all
      art = <<'EOF'
From bcmets-bounces@bcmets.org  Wed Jul  1 21:29:34 2015
From: me <me@example.com>
To: bcmets@bcmets.org
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: binary
Subject: Hi

xxx 🇨🇦yy 서 힔z

EOF

      art.lines.each { |line| parser << line.strip }
      parser.save
      article.save!
      expect(article.body).to eq "xxx yy \u{c11c} \u{d794}z\n\n"
      expect(article.charset).to eq "utf-8"
    end
  end

  describe "#content_type" do
    it "ignores encoding" do
      parser.content_type(%(text/plain; charset="iso-8859-1")).should == "text/plain"
      parser.content_type(%(text/plain; charset=iso-8859-1)).should == "text/plain"
    end

    it "ignores everything after , or ;" do
      parser.content_type(%(text/plain; charset=iso-8859-1; format=flowed)).should == "text/plain"
      parser.content_type(%(text/plain, charset=iso-8859-1, format=flowed)).should == "text/plain"
    end
  end
end
