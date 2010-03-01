require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArchiveHelper do
  describe "to_html" do
    it "should protect angle brackets" do
      helper.to_html("The <best> plan is...").should == '<p>The &lt;best&gt; plan is...</p>'
    end
    
    it "should link email addresses" do
      helper.to_html('pete@petebevin.com').should == '<p><a href="mailto:pete@petebevin.com">pete@petebevin.com</a></p>'
    end
    
    it "should decode quoted-printable messages" do
      msg = <<-END
of hospitalized patients who felt that doctors or=20
nurses =93always=94 communicated well (the=20
differences among hospitals surprised me).
END
      
      helper.to_html(msg).should =~ /or +nurses/
      helper.to_html(msg).should_not =~ /=9[34]/
    end
    
    it "should not decode quoted-printable when inappropriate" do
      helper.to_html("19+1=20 (1)").should == "<p>19+1=20 (1)</p>"
    end
    
    it "should convert stupid Windows characters to UTF8" do
      helper.to_html("it\x92s").should == "<p>it’s</p>"
    end
  end
  
  describe "last_donation" do
    it "should tell me when the most recent donation was" do
      Donation.should_receive(:last_donation_on).and_return(3.days.ago)
      helper.last_donation.should == "Last donation: 3 days ago"
    end
    
    it "should special case today" do
      Donation.should_receive(:last_donation_on).and_return(1.second.ago)
      helper.last_donation.should == "Last donation: today"
    end      
  end
end
