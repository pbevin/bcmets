module ArchiveHelper
  def month_link(year, month)
    text = "#{Date::MONTHNAMES[month]} #{year}"
    
    if year == @year && month == @month
      text = "<strong>#{text}</strong>"
    end
    
    if (year == @year && month > @month) || (year == 2001 && month == 1)
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
    wrap('pre', auto_link(h(text)))
  end
  
  def thread_as_html(article, x = "")
    # x << "<li>#{link_to article.subject, article, :class => 'subject'} <small>#{h article.from}, #{article.sent_at.to_s(:short)}</small></li>"
    x << "<li><a href=\"/archive/article/#{article.id}\" class=\"subject\">#{article.subject}</a> <small>#{h article.from}, #{article.sent_at.to_s(:short)}</small></li>"
    children = article.children
    if !children.nil? && !children.empty?
      x << "<ul>"
      for child in article.children
        thread_as_html(child, x)
      end
      x << "</ul>"
    end
    return x
  end
end

