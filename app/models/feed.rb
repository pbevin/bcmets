class Feed < ActiveRecord::Base
  attr_accessible :url

  def self.update_all()
    all.each do |feed|
      FeedEntry.update_from_feed(feed.url) or puts "Couldn't load #{feed.url}"
    end
  end
end
