module FuzzyTime
  include ActionView::Helpers::TextHelper
  extend self

  def for(tm, now=Time.now)
    diff = now - tm
    if diff < 1.minute
      "Just now"
    elsif diff < 1.hour
      minutes = (diff / 60).to_i
      pluralize minutes, "minute"
    elsif date(tm) == date(now)
      hours = (diff / 3600).to_i
      pluralize hours, "hour"
    elsif date(tm) == date(now - 1.day)
      "Yesterday, #{tm.strftime("%-I:%M%P")}"
    elsif diff < 7.days
      tm.strftime("%A, %-I:%M%P")
    elsif diff < 1.month
      tm.strftime("%b %-d, %-I:%M%P")
    elsif year(tm) == year(now)
      tm.strftime("%b %-d")
    else
      tm.strftime("%b %-d, %Y")
    end
  end

  private

  def date(tm)
    tm.strftime("%Y-%m-%d")
  end

  def year(tm)
    tm.year
  end
end
