require 'rails_helper'

describe User do
  let(:user) { User.create!(email: "test@example.com", name: "Fred") }

  let(:article) {
    Article.create(
      name: "Anita",
      email: "test2@example.com",
      subject: "Test article",
      body: "xyzzy"
    )
  }

  it "can save an article" do
    user.save_article(article)
    user.saved_articles.should == [ article ]
  end

  it "can unsave an article" do
    user.save_article(article)
    user.unsave_article(article)
    user.saved_articles.should == [ ]
  end

  describe '#reset_password!' do
    it "sends an email with the user's perishable token" do
      user.reset_password!
      message = ActionMailer::Base.deliveries.last
      message.body.should include(user.perishable_token)
    end
  end
end
