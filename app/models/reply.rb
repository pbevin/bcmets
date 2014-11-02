module Reply
  extend self

  def create_from(article)
    Article.new do |reply|
      reply.reply_type = article.reply_type
      reply.subject = subject_for_reply(article.subject)
      reply.to = article.from
      reply.parent = article
      reply.parent_id = article.id
      reply.parent_msgid = article.msgid
      reply.body = body_for_reply(article)
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

  def body_for_reply(article)
    "#{article.name} writes:\n#{quote(article.body_utf8)}"
  end

  def quote(string)
    "".tap do |body|
      lines = wrap(string).collect { |line| line.split("\n") }.flatten
      lines.each { |line| body << "> #{line}\n" }
    end
  end

  def wrap(text, columns = 72)
    text.split("\n").map do |line|
      line.length > columns ? break_line(line, columns) : line
    end
  end

  def break_line(line, columns)
    line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip
  end
end
