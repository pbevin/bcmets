class AddFeedIdToFeedEntry < ActiveRecord::Migration
  def self.up
    add_column :feed_entries, :feed_id, :integer
    FeedEntry.destroy_all
    Feed.update_all
  end

  def self.down
    remove_column :feed_entries, :feed_id
  end
end
