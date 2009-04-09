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
end
