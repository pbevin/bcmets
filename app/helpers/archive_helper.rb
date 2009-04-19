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
  
  def thread_as_html(article, x = "")
    x << "<li>"
    x << "<a href=\"/archive/article/#{article.id}\" class=\"subject\">#{h article.subject}</a> "
    x << "<small>#{link_to h(article.from), :action => "author", :email => article.email }, #{article.sent_at.to_s(:short)}</small>"
    children = article.children
    if !children.nil? && !children.empty?
      x << "<ul>"
      for child in article.children
        thread_as_html(child, x)
      end
      x << "</ul>"
    end
    x << "</li>"
    return x
  end
end

