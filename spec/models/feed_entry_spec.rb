require 'spec_helper'

describe FeedEntry do
  describe '.latest' do
    before(:each) do
      feed = Feed.create
      10.times do |n|
        feed.entries.create(
          :published_at => "2012-12-#{n}"
        )
      end
    end
    
    it "returns the latest entries" do
      FeedEntry.latest(3).should have(3).items
    end
  end

end

