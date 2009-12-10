require 'open-uri'
require 'nokogiri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed

  def self.latest(n=10)
    all(:order => "published_at DESC", :limit => n)
  end
end
