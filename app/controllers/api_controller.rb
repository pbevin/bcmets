class ApiController < ApplicationController
  def import_emails
    ImportEmails.call!
    head 204
  end

  def import_feeds
    UpdateFeeds.run
    head 204
  end

  def index_articles
    system "rake ts:index"
    head 204
  end
end
