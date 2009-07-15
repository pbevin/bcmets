class PopulateConversations < ActiveRecord::Migration
  def self.up
    execute %{
      update articles set conversation_id = null
    }
    execute %{
      delete from conversations
    }
    
    articles = Article.find(:all)
    roots = Article.thread_tree(articles)
    
    roots.each do |root|
      conversation = Conversation.create(:title => root.subject)
      root.conversation = conversation
      root.each_child do |child|
        child.conversation = conversation
        child.save
      end
    end
  end

  def self.down
  end
end
