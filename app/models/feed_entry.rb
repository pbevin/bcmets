require 'open-uri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed

  def self.latest(n)
    order("published_at DESC").limit(n).includes(:feed)
  end

  def self.from_rss_entry(entry)
    new(
      published_at: entry.published,
      name:         entry.title,
      summary:      entry.summary,
      url:          entry.url,
      guid:         entry.id
    )
  end
end
