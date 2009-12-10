require 'open-uri'
require 'nokogiri'

class FeedEntry < ActiveRecord::Base
  def self.update_from_feed(feed_url)
    content = URI.parse(feed_url).read
    if content.content_type == 'text/html'
      doc = Nokogiri::HTML(content)
      alt_url = nil
      doc.css('link[rel=alternate]').each do |node|
        alt_url = node['href'] if node['href']
      end

      if alt_url
        puts "Redirecting to #{alt_url}"
        content = URI.parse(alt_url).read
      end
    end

    feed = Feedzirra::Feed.parse(content)
    return unless feed
    feed.entries.each do |entry|
      unless exists? :guid => entry.id
        create!(
          :name         => entry.title,
          :summary      => entry.summary,
          :url          => entry.url,
          :published_at => entry.published,
          :guid         => entry.id
        )
      end
    end
  end

  def self.latest(n=10)
    all(:order => "published_at DESC", :limit => n)
  end
end
