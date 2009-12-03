require 'article_parser'

describe "Article Parser" do
  attr_accessor :article, :parser

  before(:each) do
    @article = mock()
    @parser = ArticleParser.new(article)
  end

  def accept(line)
    parser << line
  end

  def with_header(line)
    yield
    parser.header line
  end

  def with_lines(lines)
    yield
    lines.each { |line| parser << line }
  end

  it "keeps state based on where it is in the email" do
    article.stub!(:subject=)
    parser.state.should == :empty
    parser << "From blah"
    parser.state.should == :header
    parser << "Subject: xyzzy"
    parser.state.should == :header
    parser << ""
    parser.state.should == :body
  end

  it "counts the article body as anything after the first blank line" do
    with_lines ["From blah", "", "xyzzy"] do
      parser.should_receive(:body).once().with("xyzzy")
    end
  end

  it "parses the Subject line" do
    with_header "Subject: squeamish ossifrage" do
      article.should_receive(:subject=).with("squeamish ossifrage")
    end
  end

  it "strips mailing list names from the subject line" do
    with_header "Subject: Re: [bcmets] Taxol" do
      article.should_receive(:subject=).with("Re: Taxol")
    end
  end

  it "sets the received_at field based on the first line" do
    with_lines ["From bcmets-bounces@bcmets.org  Thu Mar 12 21:33:32 2009"] do
      article.should_receive(:received_at=).with("Thu Mar 12 21:33:32 2009")
    end
  end

  it "sets the sent_at field based on the Date: header" do
    with_header "Date: Thu, 12 Mar 2009 21:33:26 -0400 (EDT)" do
      article.should_receive(:sent_at=).with("Thu, 12 Mar 2009 21:33:26 -0400 (EDT)")
    end
  end

  it "parses the Message ID" do
    with_header("Message-ID: xxx") do
      article.should_receive(:msgid=).with("xxx")
    end

    # Common variant
    with_header("Message-id: yyy") do
      article.should_receive(:msgid=).with("yyy")
    end
  end

  it "sets the parent message ID" do
    with_header("In-Reply-To: <xyzzy@bcmets.org>") do
      article.should_receive(:parent_msgid=).with("<xyzzy@bcmets.org>")
    end

    # Some stupid MTA's set In-Reply-To: to <> meaning "nothing" - ignore them
    with_header("In-Reply-To: <>") do
      article.should_not_receive(:parent_msgid=)
    end
  end

  it "sets the name and email of the sender" do
    with_header "From: Mary Jones <mary@example.com>" do
      article.should_receive(:name=).with("Mary Jones")
      article.should_receive(:email=).with("mary@example.com")
    end

    with_header "From: mary@example.com" do
      article.should_receive(:name=).with("mary@example.com")
      article.should_receive(:email=).with("mary@example.com")
    end

    with_header "From: <mary@example.com>" do
      article.should_receive(:name=).with("mary@example.com")
      article.should_receive(:email=).with("mary@example.com")
    end
  end

  it "recognizes multi-part lines" do
    article.should_receive(:subject=).with("a very")
    parser.header "Subject: a very"
    article.should_receive(:subject=).with("a very long subject line")
    parser.header "   long subject line"
  end
end