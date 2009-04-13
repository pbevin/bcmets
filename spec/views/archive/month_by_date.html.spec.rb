require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/archive/month_by_date" do
  before(:each) do
    @article1 = Article.make(:received_at => DateTime.parse("Thu, 12 Mar 2009 21:33:00 -0400 (EDT)"))
    @article2 = Article.make(:received_at => DateTime.parse("Fri, 13 Mar 2009 21:33:00 -0400 (EDT)"))
    @article3 = Article.make(:received_at => DateTime.parse("Fri, 13 Mar 2009 22:46:00 -0400 (EDT)"))
    
    thu = Date.new(2009, 3, 12)
    fri = Date.new(2009, 3, 13)

    assigns[:dates] = [fri, thu]      
    assigns[:articles] = { fri => [@article3, @article2], thu => [@article1] }
    assigns[:article_count] = 3
    assigns[:year] = '2009'
    assigns[:month] = '3'
    
    render 'archive/month_by_date'
  end
  
  it "should show articles" do
    response.should have_tag("h2", "Fri Mar 13th")
    response.should have_tag("h2", "Thu Mar 12th")
  end
  
  it "should show authors" do
    response.should include_text(@article1.name)
    response.should include_text(@article1.email)
  end
  
  it "should link back to threaded view" do
    response.should have_tag("a[href=#{archive_month_path(:year => 2009, :month => 3)}]")
  end
  
end
