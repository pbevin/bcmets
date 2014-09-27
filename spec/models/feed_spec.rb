require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  let(:feed) { Feed.create }
  before(:each) do
    Timecop.freeze("2012-08-09 12:00:00")
  end
  after(:each) do
    Timecop.return
  end


  describe '#last_n_entries' do
    def create_entries(count)
      count.times do |n|
        feed.entries.create(
          created_at: n.days.ago,
          name: "Entry #{n}"
        )
      end
    end

    it "lists the most recent entries" do
      create_entries(10)
      feed.last_n_entries(3).map(&:name).should == [
        "Entry 0", "Entry 1", "Entry 2"
      ]
    end
  end

  describe '#last_entry_date' do
    it "gives the date of the most recent entry" do
      Timecop.freeze do
        feed.entries.create(created_at: 7.days.ago)
        feed.entries.create(created_at: 10.days.ago)
        feed.entries.create(created_at: 5.days.ago)
        feed.entries.create(created_at: 12.days.ago)

        feed.last_entry_date.should == 5.days.ago
      end
    end
  end
end
