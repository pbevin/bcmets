require 'open-uri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed
  attr_accessible :name, :created_at
  attr_accessible :guid, :url, :published_at, :summary

  def self.latest(n=10)
    all(:order => "published_at DESC", :limit => n)
  end
end
