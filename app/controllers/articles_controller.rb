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
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    @article.name = default_name
    @article.email = default_email

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  def reply
    @title = "Reply to Message"
    @article = Article.find_by_id(params[:id]).reply
    @article.name = default_name
    @article.email = default_email
    @article.qt = nil
    @quoted = @article.body
    @article.body = nil
    render :new
  end

  # GET /articles/1/edit
# def edit
#   @article = Article.find(params[:id])
# end

  # POST /articles
  # POST /articles.xml
  def create
    if params[:article][:body].present?
      # spam attempt!
      flash[:notice] = "Message sent."
      redirect_to root_url
      return
    end

    params[:article][:body] = params[:article][:qt]

    @article = Article.new(params[:article])
    if @article.valid?
      @article.user = current_user || User.find_by_email(@article.email)
      @article.send_via_email

      if (@article.reply_type != 'sender' && @article.user)
        #@article.save
      end

      flash[:notice] = "Message sent."
      flash[:links] = [['Home', url_for(:action => 'index')],
                       ['Current Articles', url_for(:controller => 'archive', :action => 'this_month')]]
      cookies[:name] = { :value => @article.name, :expires => 3.months.from_now, :path => "/" }
      cookies[:email] = { :value => @article.email, :expires => 3.months.from_now }
      if @article.reply?
        redirect_to article_path(@article.parent_id)
      else
        redirect_to root_url
      end
    else
      @article.body = nil
      render :new
    end
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
    user = current_user
    article = Article.find(params[:id])
    if params[:saved] == "true"
      user.save_article(article)
    else
      user.unsave_article(article)
    end
    render :json => { :status => "OK" }
  end

  def saved
    if !current_user
      return redirect_to root_url
    end
    @articles = current_user.saved_articles
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
end
