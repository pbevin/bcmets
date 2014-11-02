# Action for 'rake feeds'.  Grabs XML URL for any feeds that don't have them,
# then grabs new RSS entries.
class UpdateFeeds
  def self.run
    new.run
  end

  def run
    Feed.where(xml_url: nil).find_each do |feed|
      update_xml_url(feed)
    end
    Feed.find_each do |feed|
      update_entries(feed)
    end
  end

  def update_entries(feed)
    feed_url = feed.xml_url
    Feed.transaction do
      rss = Feedjira::Feed.fetch_and_parse(feed_url)
      return if rss.nil?
      rss.entries.each do |entry|
        feed.add_entry(FeedEntry.from_rss_entry(entry))
      end
    end
  rescue => e
    Rails.logger.warn("Failed to fetch #{feed_url}: #{e.inspect}")
  end

  def update_xml_url(feed)
    fetching(feed.url) do |content|
      doc = Nokogiri::HTML(content)
      node = doc.css('link[rel=alternate][href]').first
      update_feed(node, feed) if node
    end
  end

  private

  def update_feed(node, feed)
    href = node['href']
    title = Feedjira::Feed.fetch_and_parse(href).title
    feed.update_attributes(
      xml_url: href,
      name: title
    )
  end

  def fetching(url)
    content = URI.parse(url).read
    yield content if content.content_type == 'text/html'
  end
end
