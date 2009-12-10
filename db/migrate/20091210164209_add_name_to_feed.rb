class AddNameToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :name, :string
    add_column :feeds, :xml_url, :string
  end

  def self.down
    remove_column :feeds, :name
    remove_column :feeds, :xml_url
  end
end
