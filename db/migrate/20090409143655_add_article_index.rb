class AddArticleIndex < ActiveRecord::Migration
  def self.up
    add_index :articles, :msgid
    add_index :articles, :received_at
    add_index :articles, :email
    add_index :articles, :parent_msgid
  end

  def self.down
    remove_index :articles, :parent_msgid
    remove_index :articles, :email
    remove_index :articles, :received_at
    remove_index :articles, :msgid
  end
end
