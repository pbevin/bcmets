class Archive
  def self.in_range(year, month)
    this_year = Date.today.year
    (2000..this_year).include?(year.to_i) && (1..12).include?(month.to_i)
  end
end
