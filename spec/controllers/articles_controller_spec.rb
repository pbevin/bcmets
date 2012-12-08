require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticlesController do
  def mock_article(stubs={})
    @mock_model ||= mock_model(Article, stubs)
  end

  describe "GET index" do
    it "redirects to /archive" do
      get :index
      response.should redirect_to root_url
    end
  end

  describe "GET show" do
    it "assigns the requested article as @article" do
      article = Article.make!
      Article.stub!(:find).with("37").and_return(article)
      get :show, :id => "37"
      assigns[:article].should equal(article)
    end

    it "retrieves the conversation thread" do
      article = Article.new
      conversation = Conversation.new()
      3.times { conversation.articles << Article.new }

      Article.should_receive(:find).once().with("37").and_return(article)
      article.should_receive(:conversation).once().and_return(conversation)
      get :show, :id => "37"
      assigns[:article].should equal(article)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested article" do
      Article.should_receive(:find).with("37").and_return(mock_article)
      mock_article.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the articles list" do
      Article.stub!(:find).and_return(mock_article(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(articles_url)
    end
  end
end
