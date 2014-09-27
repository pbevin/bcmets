require 'open-uri'
require 'nokogiri'

class Feed < ActiveRecord::Base
  has_many :entries, class_name: "FeedEntry"

  def last_n_entries(n)
    entries.order("created_at DESC").limit(n)
  end

  def last_entry_date
    entries.order("created_at DESC").first.created_at
  end

  def has_entry?(guid: nil)
    entries.map(&:guid).include?(guid)
  end

  def add_entry(entry)
    entries << entry unless has_entry?(guid: entry.guid)
  end
end
