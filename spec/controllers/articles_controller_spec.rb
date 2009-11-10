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
      Article.stub!(:find).with("37").and_return(mock_article)
      get :show, :id => "37"
      assigns[:article].should equal(mock_article)
    end
  end

  describe "GET new" do
    it "assigns a new article as @article" do
      get :new
      assigns[:article].should be_new_record
    end
  end

  describe "GET edit" do
    it "assigns the requested article as @article" do
      Article.stub!(:find).with("37").and_return(mock_article)
      get :edit, :id => "37"
      assigns[:article].should equal(mock_article)
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
