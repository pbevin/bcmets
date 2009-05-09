class IndexArticlesByConversation < ActiveRecord::Migration
  def self.up
    add_index :articles, :conversation_id
  end

  def self.down
    remove_index :article, :conversation_id
  end
end
