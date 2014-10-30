module FuzzyTime
  extend self

  def for(tm, now=Time.now)
    minutes = (now - tm) / 60
    "#{minutes} minutes"
  end
end
