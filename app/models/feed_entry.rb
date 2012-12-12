require 'open-uri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed
  attr_accessible :name, :created_at
  attr_accessible :guid, :url, :published_at, :summary

  scope :latest, lambda { |n|
    order("published_at DESC").limit(n).includes(:feed)
  }
end
