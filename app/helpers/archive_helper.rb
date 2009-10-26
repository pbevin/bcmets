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
    # if author.user
    #   return user_linked(author.user)
    # elsif author.name == author.email
    #   return email_linked(author)
    # else
    #   return author.name + " &lt;" + email_linked(author) + "&gt;"
    # end
  end
  
  def email_linked(author)
    link_to author.email, :controller => "archive", :action => "author", :email => author.email
  end
  
  def user_linked(user)
    link_to user.name, user_profile_path(user), :class => "user"
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
    begin
      text = Iconv.conv('utf-8', 'WINDOWS-1252', text)
    rescue
    end
    text
  end
  
  def thread_as_html(articles)
    # Rails.cache.fetch("thread.#{@year}.#{@month}", :expires_in => 1.minute) { th(articles, "") }
    th(articles, "")
  end
  
  def th(articles, x)
    for article in articles
      x << "<li>"
      x << link_to_article(article) << " "
      #x << "<small>#{link_to_author(article)}, #{article.sent_at.to_s(:short)}</small>"
      x << "<small>#{from_linked(article)}, #{article.sent_at.to_s(:short)}</small>"
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
  
  def donations_this_month
    amount = Donation.total_this_month
    "#{number_to_currency(amount, :precision => 0)} this month (target: $500)"
  end
  
  def donations_this_year
    amount = Donation.total_this_year
    "#{number_to_currency(amount, :precision => 0)} this year (target: $6,000)"
  end
  
  def last_donation
    date = Donation.last_donation_on
    if date == nil
      last_donation = "never"
    elsif date.to_date == Date.today
      last_donation = "today"
    else
      last_donation = "#{time_ago_in_words(date)} ago"
    end
    "Last donation: #{last_donation}"
  end

  def link_to_author(article)
    "<a href=\"/archive/author?email=#{URI.escape(article.email)}\">#{h article.from}</a>"
  end
  
  def link_to_article(article)
    "<a href=\"/archive/article/#{article.id}\" class=\"subject\">#{h article.subject}</a>"
  end
end

