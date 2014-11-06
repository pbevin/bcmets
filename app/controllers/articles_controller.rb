class ArticlesController < ApplicationController
  # GET /articles
  # GET /articles.xml
  def index
    redirect_to root_url
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = Article.find(params[:id])
    begin
      @conversation_roots = Article.thread_tree(@article.conversation.articles)
    rescue
      @conversation_roots = nil
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    article = Article.new

    article.name = default_name
    article.email = default_email

    respond_to do |format|
      format.html { render locals: { article: article, title: nil, quoted: nil } }
      format.xml  { render xml: article }
    end
  end

  def reply
    article = Article.find_by_id(params[:id]).reply
    article.name = default_name
    article.email = default_email
    article.qt = nil
    article.body = nil
    render :new, locals: { article: article, quoted: article.body, title: "Reply to Message" }
  end

  # GET /articles/1/edit
  # def edit
  #   @article = Article.find(params[:id])
  # end

  class CreatePostResponder < SimpleDelegator
    def spam
      flash[:notice] = "Message sent."
      redirect_to root_url
    end

    def sent(article, parent)
      flash[:notice] = "Message sent."
      flash[:links] = [['Home', url_for(action: 'index')],
                       ['Current Articles', url_for(controller: 'archive', action: 'this_month')]]
      cookies[:name] = { value: article.name, expires: 3.months.from_now, path: "/" }
      cookies[:email] = { value: article.email, expires: 3.months.from_now }
      if parent
        redirect_to article_path(parent)
      else
        redirect_to root_url
      end
    end

    def invalid(article)
      @article = article
      render :new, locals: { article: article, quoted: nil, title: "Reply to Message" }
    end

    def cookies
      request.cookie_jar
    end
  end

  # POST /articles
  # POST /articles.xml
  def create
    responder = CreatePostResponder.new(self)
    SendArticle.new(responder).call(current_user, article_params)
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end

  def set_saved
    p session: UserSession.find
    user = current_user
    return render json: { succeeded: false, error: "not logged in" } if !user
    article = Article.find(params[:id])
    if params[:saved] == "true"
      user.save_article(article)
      saved = true
    else
      user.unsave_article(article)
      saved = false
    end
    render json: { succeeded: true, saved: saved }
  end

  def saved
    if !current_user
      return redirect_to root_url
    end
    @articles = current_user.saved_articles
  end

  def is_saved
    article = Article.find(params[:id])
    saved = current_user ? article.saved_by?(current_user) : nil
    render json: { saved: saved }
  end

  private

  def cookie_or_user(attr)
    cookies[attr] || (current_user && current_user.send(attr))
  end

  def default_name
    cookie_or_user(:name)
  end

  def default_email
    cookie_or_user(:email)
  end

  def article_params
    params.require(:article).permit(:name, :email, :subject, :qt, :body, :to, :parent_msgid, :parent_id, :reply_type)
  end
end
