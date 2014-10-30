require 'rails_helper'

describe ArticlesController do
  let(:article) { Article.make! }
  let(:article_id) { article.id.to_s }

  describe "GET index" do
    it "redirects to /archive" do
      get :index
      response.should redirect_to root_url
    end
  end

  describe "GET show" do
    it "assigns the requested article as @article" do
      get :show, id: article_id
      assigns[:article].should eq(article)
    end

    it "retrieves the conversation thread" do
      conversation = Conversation.new
      articles = []
      3.times { articles << Article.make!(conversation: conversation) }
      conversation.articles = articles

      article = articles.second

      get :show, id: article.id.to_s
      assigns[:article].should eq(article)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested article and redirects to the article list" do
      delete :destroy, id: article_id
      response.should redirect_to(articles_url)
    end
  end
end
