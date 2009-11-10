class ArchiveController < ApplicationController
  before_filter :disable_search_engines
  
  def index
    @heading = "Archives"
    @year = Time.now.year
    @month = Time.now.month
  end

  def month
    if params[:old_year_month]
      @year, @month = old_year_month
    else
      @year, @month = params[:year], params[:month]
    end
    @title = "#{Date::MONTHNAMES[@month.to_i]} #{@year}"
    @heading = @title
    
    candidates = Article.for_month(@year.to_i, @month.to_i)
    @articles = Article.thread_tree(candidates)
    @article_count = candidates.count
    
    expires_in 2.minutes
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
    begin
      @conversation_roots = Article.thread_tree(@article.conversation.articles)
    rescue
      @conversation_roots = nil
    end
  end
  
  # For people with legacy bookmarks - can probably remove this feature after Dec 2010.
  def old_article
    year, month = old_year_month
    article_number = params[:article_number]
    @article = Article.find_by_legacy_id("#{year}-#{month}/#{article_number}")
    if @article.nil?
      flash[:notice] = "Oops.  We couldn't find your bookmark.  You can use the Search function to try and locate it, or click on a month below."
      redirect_to :action => "index"
    else
      redirect_to :action => "article", :id => @article
    end
  end
  
  def search
    @q = params['q']
    order = params['sort']
    
    @title = @q
    
    search_options = {
      :page => (params['page'] || 1),
      :field_weights => { "subject" => 10, "name" => 5, "email" => 5, "body" => 1 },
    }
    if order == 'date'
      search_options.merge!(:order => :received_at, :sort_mode => :desc)
      @sorting_by = "date"
      @switch_sort = "relevance"
      @switch_url = url_for(:action => "search", :q => @q)
    else
      @sorting_by = "relevance"
      @switch_sort = "date"
      @switch_url = url_for(:action => "search", :q => @q, :sort => 'date')
    end
    
    begin
      @articles = Article.search(@q, search_options)
    rescue
      @articles = [].paginate
      flash[:notice] = "Sorry, search isn't working right now. Please give <a href=\"mailto:owner@bcmets.org\">Pete</a> a kick."
    end
  end

  def author
    Struct.new("Author", :name, :email)
    @author = Struct::Author.new(params[:name], params[:email])
    @articles = Article.find_all_by_email(params[:email], :order => "sent_at DESC")
  end
  
  def this_month
    redirect_to url_for(:action => 'month', :year => Date.today.year, :month => Date.today.month)
  end

  private

  def send_via_email(article)
    article.send_via_email
  end
  
  def disable_search_engines
    @indexable = (params[:action] == 'index')
  end
  
  def old_year_month
    params[:old_year_month] =~ /(\d{4})-(\d{2})/ && [$1, $2]
  end
end
