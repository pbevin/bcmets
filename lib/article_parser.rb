class ArticleParser
  attr_accessor :article, :state, :current_line

  def initialize(article)
    self.article = article
    self.state = :empty
    self.current_line = ''
    @body = ''
  end

  def <<(line)
    case state
    when :empty
      first_line(line)
      self.state = :header
    when :header
      if line == ""
        self.state = :body
      else
        header(line)
      end
    when :body
      body(line)
    else
      raise "Article parser: funny state #{state.inspect}"
    end
  end

  def first_line(line)
    case line
    when /^From (.*?)  (.*)$/
      article.received_at = $2
    end
  end

  def header(line)
    case line
    when /^\s+(.*)/
      self.current_line += ' ' + $1
      return header(@current_line)
    when /^From: (.*) <(.*)>$/
      article.name = $1
      article.email = $2
    when /^From: <(.*)>$/, /^From: (.*)$/
      article.name = article.email = $1
    when /^Subject: (.*)$/
      article.subject = $1.gsub(/\[.*\]\s*/, '')
    when /^Message-ID: (.*)$/i
      article.msgid = $1
    when /^Date: (.*)$/
      article.sent_at = $1
    when /^In-Reply-To: (<.+>)$/i
      article.parent_msgid = $1
    when /^Content-Type: (.*)$/i
      article.content_type = content_type($1)
    when /^References: (<.+?>).*$/i
      article.parent_msgid = $1 if article.parent_msgid.blank?
    end
    self.current_line = line
  end

  def body(line)
    @body += line + "\n"
  end

  def save
    article.body = converted_body
  end

  def content_type(original)
    original.gsub(/[,;].*/, "")
  end

  def converted_body
    CharsetFixer.new("utf-8").fix(@body)
  end
end
