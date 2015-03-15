module Reply
  extend self

  def create_from(article)
    Article.new do |reply|
      reply.reply_type = article.reply_type
      reply.subject = subject_for_reply(article.subject)
      reply.parent_id = article.id
    end
  end

  def subject_for_reply(subject)
    case subject
    when /^Re:/i
      subject
    else
      "Re: #{subject}"
    end
  end
end
