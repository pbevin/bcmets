module LinkThreads
  extend self

  def run(since=6.months.ago)
    articles_to_link = Article.where("parent_msgid != '' and parent_id is null and created_at > ?", since)
    articles_to_link.each do |article|
      parent = Article.find_by(msgid: article.parent_msgid)
      if !parent.nil?
        article.parent_id = parent.id
        if article.conversation.nil?
          article.conversation = parent.conversation
        else
          Article.where(conversation_id: article.conversation_id).update_all(conversation_id: parent.conversation_id)
        end
      end
      article.save
    end
  end

end
