require 'open-uri'

class FeedEntry < ActiveRecord::Base
  belongs_to :feed

  def self.latest(n)
    order("published_at DESC").limit(n).includes(:feed)
  end
end
