require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArchiveHelper do
  describe "to_html" do
    it "should protect angle brackets" do
      helper.to_html("The <best> plan is...").should == '<p>The &lt;best&gt; plan is...</p>'
    end
    
    it "should link email addresses" do
      helper.to_html('pete@petebevin.com').should == '<p><a href="mailto:pete@petebevin.com">pete@petebevin.com</a></p>'
    end
    
    it "should wrap long lines"
  end
end
