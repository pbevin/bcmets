require "rails_helper"

describe MessageParser do
  let(:parser) { MessageParser.new }
  describe "Parsing a simple message with base64 body" do
    message = <<'EOF'
From bcmets-bounces@bcmets.org  Mon Jan  5 14:40:38 2018
Return-Path: <bcmets-bounces@bcmets.org>
X-Original-To: metsarch@bcmets.org
Delivered-To: metsarch@bcmets.org
Date: Fri, 05 Jan 2018 14:40:36 +0000
From: List Member <listmember@example.com>
To: bcmets@bcmets.org
Message-ID: <abc123@bcmets.org>
In-Reply-To: <abcdef@mail.yahoo.com>
References: <abcdef@mail.yahoo.com>
 <ghijkl@mail.yahoo.com>
X-Mailman-Version: 2.1.23
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Subject: Test message.

VGhpcyBpcyBhIG1lc3NhZ2UuCg==
EOF
    let(:message) { message }
    subject { parser.parse(message) }

    it { is_expected.to be_a_kind_of(Article) }
    it { is_expected.to have_attributes(body: "This is a message.\n") }
    it { is_expected.to have_attributes(subject: "Test message.") }
    it { is_expected.to have_attributes(received_at: Time.utc(2018, 1, 5, 14, 40, 38)) }
    it { is_expected.to have_attributes(sent_at: Time.utc(2018, 1, 5, 14, 40, 36)) }
    it { is_expected.to have_attributes(name: "List Member") }
    it { is_expected.to have_attributes(email: "listmember@example.com") }
    it { is_expected.to have_attributes(parent_msgid: "<abcdef@mail.yahoo.com>") }
    it { is_expected.to have_attributes(msgid: "<abc123@bcmets.org>") }
  end

  specify "Body parsing: not multipart" do
    body = instance_double(
      Mail::Body,
      decoded: "this is the body"
    )
    msg = instance_double(
      Mail::Message,
      body: body,
      mime_type: "text/plain",
      multipart?: false
    )
    expect(parser.parse_body(msg)).to eql("this is the body")
  end

  specify "Body parsing: walking the tree" do
    leaf1 = instance_double(
      Mail::Part,
      multipart?: false,
      mime_type: "text/plain",
      decoded: "This is the main body.\n"
    )
    leaf2 = instance_double(
      Mail::Part,
      multipart?: false,
      mime_type: "text/html",
      decoded: "<p>This is the HTML version</p>\n"
    )
    leaf3 = instance_double(
      Mail::Part,
      multipart?: false,
      mime_type: "text/plain",
      decoded: "This is the footer.\n"
    )
    part1 = instance_double(
      Mail::Part,
      multipart?: true,
      mime_type: "multipart/alternative",
      parts: [leaf1, leaf2]
    )
    body = instance_double(
      Mail::Body,
      parts: [part1, leaf3]
    )
    msg = instance_double(
      Mail::Message,
      body: body,
      mime_type: "multipart/alternative",
      multipart?: true
    )

    expect(parser.parse_body(msg)).to eql([
      "This is the main body.\n",
      "This is the footer.\n"
    ].join)
  end

  specify "Incorrect envelope From line" do
    text = <<'.'
From name@example.com  Thu 10 Dec 2015 13:45:20 +0000
From: Test <test@example.com>
Date: Thu 10 Dec 2015 13:25:06 +0000
Message-ID: <1234@example.com>
Subject: [bcmets] This is a very
  long subject line

body
.
    article = parser.parse(text)
    expect(article).to have_attributes(
      received_at: Time.utc(2015, 12, 10, 13, 45, 20)
    )
  end

  describe "#fix_subject" do
    it "removes extra spaces" do
      expect(parser.fix_subject("a  b   c")).to eql("a b c")
    end

    it "removes the initial [bcmets]" do
      expect(parser.fix_subject("[bcmets] a b c")).to eql("a b c")
    end
  end

  describe "parse_parent" do
    specify "Nil fields" do
      expect(parser.parse_parent(nil, nil)).to be_nil
    end
    specify "Blank fields" do
      expect(parser.parse_parent("", "")).to be_nil
    end
    specify "IRT is <>" do
      expect(parser.parse_parent("<>", "")).to be_nil
    end
    specify "IRT is <> and References has a ref" do
      expect(parser.parse_parent("<>", "abc")).to eql("<abc>")
    end
    specify "IRT is <> and References has a ref" do
      expect(parser.parse_parent("<>", "abc")).to eql("<abc>")
    end
    specify "IRT is blank and References is a string" do
      expect(parser.parse_parent("", "abc")).to eql("<abc>")
    end
    specify "IRT is blank and References is a string" do
      expect(parser.parse_parent("", ["abc", "def"])).to eql("<abc>")
    end
    specify "IRT is present and References is a string" do
      expect(parser.parse_parent("xyz", ["abc", "def"])).to eql("<xyz>")
    end
  end
end
