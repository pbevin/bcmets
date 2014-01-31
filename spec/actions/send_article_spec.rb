require 'spec_helper'

describe SendArticle do
  let(:responder) { double("responder") }
  let(:send_article) { SendArticle.new(responder) }

  it "calls .spam if params has a :body set" do
    # This is a spam honey trap: the form has a body textarea that is
    # hidden, and the real body is under the key :qt

    responder.should_receive(:spam)
    send_article.call(nil, body: "make money fast")
  end

  it "calls .invalid if the article is invalid but not spam" do
    Article.any_instance.stub(valid?: false)
    responder.should_receive(:invalid).with(an_instance_of(Article))
    send_article.call(nil, qt: "invalid article")
  end

  it "calls .sent if the article is valid" do
    Article.any_instance.stub(valid?: true)

    responder.should_receive(:sent).with(an_instance_of(Article), nil)

    send_article.call(
      nil,
      name: "Bob Example",
      email: "a@example.com",
      qt: "valid article"
    )
  end
end

