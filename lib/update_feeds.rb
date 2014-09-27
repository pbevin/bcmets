class UpdateFeeds

  def self.run
    new.run
  end

  def run
    Feed.find_each do |feed|
      update_feed_data(feed) if !feed.xml_url
      update_entries(feed)
    end
  end

  def update_entries(feed)
    feed_url = feed.xml_url
    begin
      Feed.transaction do
        rss = Feedjira::Feed.fetch_and_parse(feed_url)
        return if rss.nil? # || rss.is_a?(Fixnum)
        rss.entries.each { |entry| add_entry_to_feed(entry, feed) }
      end
    rescue => e
      Rails.logger.warn("Failed to fetch #{feed_url}: #{e.inspect}")
    end
  end

  def add_entry_to_feed(entry, feed)
    unless FeedEntry.exists?(guid: entry.id)
      feed.entries << FeedEntry.new(
        published_at: entry.published,
        name:         entry.title,
        summary:      entry.summary,
        url:          entry.url,
        guid:         entry.id
      )
    end
  end

  def update_feed_data(feed)
    content = URI.parse(feed.url).read
    if content.content_type == 'text/html'
      doc = Nokogiri::HTML(content)
      if node = doc.css('link[rel=alternate][href]').first
        href = node['href']
        feed.update_attributes(
          xml_url: href,
          name: Feedjira::Feed.fetch_and_parse(feed.xml_url).title
        )
      end
    end
  end
end
