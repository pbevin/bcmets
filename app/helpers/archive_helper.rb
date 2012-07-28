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
    links = articles.map do |article|
      link = link_to(article.subject, article, :class => 'subject')
      wrap('li', link)
    end

    return wrap('ul', links.join)
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
    auto_link(simple_format(h(text)))
  end

  def thread_as_html(articles)
    # Rails.cache.fetch("thread.#{@year}.#{@month}", :expires_in => 1.minute) { th(articles, "") }
    th(articles, "")
  end

  def th(articles, x)
    articles.each do |article|
      x << "<li>"
      x << link_to_article(article) << " "
      x << "<small>#{from_linked(article)}, #{article.sent_at_human}</small>"
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

  def donations(collected, message)
    "#{number_to_currency(collected, :precision => 0)} this #{message}"
  end

  def donations_this_month
    donations Donation.total_this_month, "month (target: $500)"
  end

  def donations_this_year
    donations Donation.total_this_year, "year (target: $6,000)"
  end

  def last_donation
    date = Donation.last_donation_on
    if date == nil
      last_donation = "never"
    elsif date.to_date == Time.zone.today
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
    link = %Q{<a class="pjax" href="/articles/#{article.id}" class="subject">#{h article.subject}</a>}
    if article.saved_by?(current_user)
      link = %Q{<span class="star selected"></span>} + link
    end

    return link
  end
end
