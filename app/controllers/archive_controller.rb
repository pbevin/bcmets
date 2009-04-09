class ArchiveController < ApplicationController
  def index
    @year = Time.now.year
    @month = Time.now.month
  end

  def month
    @year, @month = params[:year], params[:month]
    @articles = Article.find(:all)
  end

  def article
  end

end
