require 'open-uri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed

  scope :latest, lambda { |n|
    order("published_at DESC").limit(n).includes(:feed)
  }
end
