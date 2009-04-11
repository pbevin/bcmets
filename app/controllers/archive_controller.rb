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
  end

  def article
    @article = Article.find_by_id(params[:id])
    @title = @article.subject
  end

end
