module ArchiveHelper
  def month_link(year, month)
    text = "#{Date::MONTHNAMES[month]} #{year}"

    if year == @year && month == @month
      text = "<strong>#{text}</strong>"
    end

    if (year == @year && month > @month) || (year == 2000 && month == 1)
      return text
    end

    link_to text.html_safe, archive_month_path(year, month)
  end

  def from_linked(author)
    if author.name == author.email
      from = email_linked(author)
    else
      from = author.name + " &lt;" + email_linked(author) + "&gt;"
    end
    from.html_safe
  end

  def email_linked(author)
    %(<a href="/archive/author?email=#{URI.escape author.email}">#{h author.email}</a>)
  end

  def wrap(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end

  def to_html(text)
    ArticleBodyFormatter.new.format(text)
  end

  def thread_as_html(articles, out = "")
    articles.each do |article|
      out << "<li>"
      out << link_to_article(article) << " "
      out << "<small>#{from_linked(article)}, #{article.sent_at_human}</small>"
      children = article.children
      if !children.nil? && !children.empty?
        out << "<ul>"
        thread_as_html(children, out)
        out << "</ul>"
      end
      out << "</li>"
    end
    out
  end

  def donations(collected, message)
    "#{number_to_currency(collected, precision: 0)} this #{message}"
  end

  def donations_this_month
    donations Donation.total_this_month, "month (target: $500)"
  end

  def donations_this_year
    donations Donation.total_this_year, "year (target: $6,000)"
  end

  def last_donation
    date = Donation.last_donation_on
    if date.nil?
      last_donation = "never"
    elsif date.to_date == Time.zone.today
      last_donation = "today"
    else
      last_donation = "#{time_ago_in_words(date)} ago"
    end
    "Last donation: #{last_donation}"
  end

  def link_to_author(article)
    path = {
      controller: "archive",
      action: "author",
      email: article.email
    }
    link_to h(article.from), path
  end

  def link_to_article(article)
    link = %(<a href="/articles/#{article.id}" class="subject">#{h article.subject}</a>)
    if article.saved_by?(current_user)
      link = %(<span class="star selected"></span>) + link
    end

    link.html_safe
  end
end
