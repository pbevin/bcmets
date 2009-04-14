class ArchiveController < ApplicationController
  def index
    @title = "Archives"
    @year = Time.now.year
    @month = Time.now.month
  end

  def month
    @year, @month = params[:year], params[:month]
    @title = "#{Date::MONTHNAMES[@month.to_i]} #{@year}"
    
    candidates = Article.for_month(@year.to_i, @month.to_i)
    
    @articles = Article.thread_tree(candidates)
    @article_count = candidates.count
  end
  
  def month_by_date
    @year, @month = params[:year], params[:month]
    @title = "#{Date::MONTHNAMES[@month.to_i]} #{@year}"
        
    candidates = Article.for_month(@year.to_i, @month.to_i)
    @articles = candidates.group_by {|article| article.received_at.to_date}
    @dates = @articles.keys.sort { |a,b| b <=> a }
    @article_count = candidates.count
  end

  def article
    @article = Article.find_by_id(params[:id])
    @title = @article.subject
  end

  def post
    if request.post?
      @article = Article.new(params[:article])
      if @article.valid?
        @article.prepare_for_email
        send_via_email(@article)
        @article.save
        flash[:notice] = "Message sent."
        redirect_to :action => "index"
      end
    else
      @article = Article.new
    end
  end
  
  def send_via_email(article)
    article.send_via_email
  end
end
