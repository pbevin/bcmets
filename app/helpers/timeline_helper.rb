module TimelineHelper
  def fuzzy_time(tm)
    FuzzyTime.for(tm)
  end
end
