require 'will_paginate/array'

class ArchiveController < ApplicationController
  before_filter :enable_search_engines, :only => :index

  def index
    now = Time.zone.now
    @year = now.year
    @month = now.month
  end

  def month
    if params[:old_year_month]
      @year, @month = old_year_month
    else
      @year, @month = params[:year], params[:month]
    end
    month_year = "#{Date::MONTHNAMES[@month.to_i]} #{@year}"
    @title = month_year

    if @year.to_i > Date.today.year || @year.to_i < 2000 || @month.to_i < 1 || @month.to_i > 12
      flash[:notice] = "No articles for #{@month}/#{@year}"
      return redirect_to root_url
    end

    candidates = Article.for_month(@year.to_i, @month.to_i)
    @articles = Article.thread_tree(candidates).reverse
    @article_count = candidates.count

    expires_in 2.minutes
  end

  def month_by_date
    @year, @month = params[:year], params[:month]
    @title = "#{Date::MONTHNAMES[@month.to_i]} #{@year}"

    candidates = Article.for_month(@year.to_i, @month.to_i, "received_at DESC")
    @articles = candidates.group_by {|article| article.received_at.to_date}
    @dates = @articles.keys.sort { |a,b| b <=> a }
    @article_count = candidates.count
  end

  def article
    @article = Article.find_by_id(params[:id])
    redirect_to @article
  end

  # For people with legacy bookmarks - can probably remove this feature after Dec 2010.
  def old_article
    year, month = old_year_month
    article_number = params[:article_number]
    @article = Article.find_by_legacy_id("#{year}-#{month}/#{article_number}")
    if @article.nil?
      flash[:notice] = "Oops.  We couldn't find your bookmark.  " +
          "You can use the Search function to try and locate it, or click on a month below."
      redirect_to :action => "index"
    else
      redirect_to :action => "article", :id => @article
    end
  end

  def search
    @search = SearchOptions.new(params)
    @title = @search.query
    if @search.error
      flash[:notice] = @search.error.html_safe
    end
  end

  def author
    @email = params[:email]
    @articles = Article.find_all_by_email(params[:email], :order => "sent_at DESC")
    unless params[:page] == "all"
      @articles = @articles.paginate(:page => params[:page])
      @pagination = true
    end
  end

  def this_month
    date = Time.zone.today
    redirect_to url_for(:action => 'month', :year => date.year, :month => date.month)
  end

  private

  def send_via_email(article)
    article.send_via_email
  end

  def enable_search_engines
    @indexable = true
  end

  def old_year_month
    params[:old_year_month] =~ /(\d{4})-(\d{2})/ && [$1, $2]
  end
end
