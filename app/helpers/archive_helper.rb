module ArchiveHelper
  def month_link(year, month)
    text = "#{Date::MONTHNAMES[month]} #{year}"
    
    if year == @year && month == @month
      text = "<strong>#{text}</strong>"
    end
    
    if (year == @year && month > @month) || (year == 2000 && month == 1)
      return text
    end

    return link_to text, archive_month_path(year, month)    
  end
  
  def threaded_articles(articles)
    html = ''
    
    for article in articles
      html += wrap('li', link_to(article.subject, article, :class => 'subject'))
    end
    
    return wrap('ul', html)
  end
  
  
  def from_linked(author)
    if author.name == author.email
      return email_linked(author)
    else
      return author.name + " &lt;" + email_linked(author) + "&gt;"
    end
  end
  
  def email_linked(author)
    link_to author.email, :controller => "archive", :action => "author", :email => author.email
  end
  
  def wrap(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
  
  def to_html(text)
    if (text =~ /=20$/)
      text.gsub!(/=20\n/, " ")
      text.gsub!(/=\n/, "")
      text.gsub!(/\n/m, $/)
      text.gsub!(/=([\dA-F]{2})/) { $1.hex.chr }
    end
    text = auto_link(simple_format(h(text)))
    text = Iconv.conv('utf-8', 'WINDOWS-1252', text)
  end
  
  def thread_as_html(articles)
    Rails.cache.fetch("thread.#{@year}.#{@month}") { th(articles, "") }
  end
  
  def th(articles, x)
    for article in articles
      x << "<li>"
      x << "<a href=\"/archive/article/#{article.id}\" class=\"subject\">#{h article.subject}</a> "
      x << "<small><a href=\"/archive/author/#{URI.escape(article.email)}\">#{h article.from}</a>, #{article.sent_at.to_s(:short)}</small>"
      children = article.children
      if !children.nil? && !children.empty?
        x << "<ul>"
        th(children, x)
        x << "</ul>"
      end
      x << "</li>"
    end
    return x
  end

  def link_to_author(article)
    "<a href=\"/archive/author?email=#{URI.escape(article.email)}\">#{h article.from}</a>"
  end
  
  def link_to_article(article)
    "<a href=\"/archive/article/#{article.id}\" class=\"subject\">#{h article.subject}</a>"
  end
end

