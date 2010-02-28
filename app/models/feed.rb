require 'open-uri'
require 'nokogiri'

class Feed < ActiveRecord::Base
  has_many :entries, :class_name => "FeedEntry"
  attr_accessible :url

  def self.update_all()
    all.each do |feed|
      if !feed.xml_url
        feed.update_feed_data
      end

      # FeedEntry.update_from_feed(feed.xml_url) or puts "Couldn't load #{feed.url}"
      feed.update_entries
    end
  end

  def update_entries(feed_url = self.xml_url)
    Feed.transaction do
      feed = Feedzirra::Feed.fetch_and_parse(feed_url)
      return unless feed || feed.is_a?(Fixnum)
      feed.entries.each do |entry|
        unless FeedEntry.exists? :guid => entry.id
          entries << FeedEntry.create!(
            :name         => entry.title,
            :summary      => entry.summary,
            :url          => entry.url,
            :published_at => entry.published,
            :guid         => entry.id
          )
        end
      end
    end
  end

  def update_feed_data
    content = URI.parse(url).read
    if content.content_type == 'text/html'
      doc = Nokogiri::HTML(content)
      doc.css('link[rel=alternate]').each do |node|
        if node['href']
          self.xml_url = node['href'] if node['href']
          self.name = parsed_feed.title
          save
          return
        end
      end
    end
  end

  def parsed_feed
    @parsed ||= Feedzirra::Feed.fetch_and_parse(xml_url)
  end
end
