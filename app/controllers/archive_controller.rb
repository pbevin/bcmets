class ArchiveController < ApplicationController
  def index
    @year = Time.now.year
    @month = Time.now.month
  end

  def month
    @year, @month = params[:year], params[:month]
    @articles = Article.find(:all, :order => "received_at DESC")
  end

  def article
    @article = Article.find_by_id(params[:id])
  end

end
