require 'spec_helper'


describe UpdateFeeds do
  describe '#update_entries' do
    let(:updater) { UpdateFeeds.new }
    let(:path) { "spec/data/feed.xml" }
    let(:xml_url) { "file://" + File.absolute_path(path) }
    let(:feed)    { Feed.new(xml_url: xml_url) }

    it "updates from an XML feed" do
      updater.update_entries(feed)
      feed.entries.map(&:name).should == [
        "Entry One",
        "Entry Two"
      ]
    end

    it "ignores duplicate entries" do
      feed.entries << FeedEntry.new(
        guid: "https://example.wordpress.com/?p=148",
        name: "Original Entry"
      )

      updater.update_entries(feed)
      feed.entries.map(&:name).should == [
        "Original Entry",
        "Entry One"
      ]

    end

    it "ignores XML feeds it can't load" do
      feed.xml_url = "file://does/not/exist.xml"
      updater.update_entries(feed)
      feed.entries.should be_empty
    end
  end
end
