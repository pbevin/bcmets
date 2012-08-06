class Donation < ActiveRecord::Base
  validates_presence_of :amount
  validates_presence_of :email
  validates_presence_of :date
  validates_numericality_of :amount

  attr_accessible :date, :amount, :email

  def self.total_this_month(date = Time.zone.today)
    start_of_month = Date.new(date.year, date.month, 1)
    end_of_month = 1.month.since(start_of_month)
    self.sum(:amount, :conditions => ["date >= ? and date < ?", start_of_month, end_of_month])
  end

  def self.total_this_year(date = Time.zone.today)
    start_of_year = Date.new(date.year, 1, 1)
    end_of_year = 1.year.since(start_of_year)
    self.sum(:amount, :conditions => ["date >= ? and date < ?", start_of_year, end_of_year])
  end

  def self.last_donation_on
    self.maximum(:date)
  end
end
