require 'maxmind'

describe "MaxMind library" do
  it "parses descriptions" do
    datapipe = MaxMind.parse("US,NJ,Jersey City,40.724499,-74.062103")
    datapipe.country.should == "US"
    datapipe.state.should == "NJ"
    datapipe.city.should == "Jersey City"
  end
  
  it "parses null correctly" do
    bigpond = MaxMind.parse("AU,(null),(null),111,111")
    bigpond.state.should be_nil
    bigpond.city.should be_nil
  end
  
  it "omits US for US addresses" do
    MaxMind::City.new("US", "NJ", "Jersey City").to_s.should == "Jersey City, NJ"
  end
  
  it "omits state when it's numeric" do
    MaxMind::City.new("UK", "A7", "Birmingham").to_s.should == "Birmingham UK"
  end
  
  it "replaces GB with UK" do
    MaxMind::City.new("GB", "A7", "Birmingham").to_s.should == "Birmingham UK"
  end
  
  it "omits nil fields" do
    MaxMind::City.new("AU", nil, nil).to_s.should == "AU"
    MaxMind::City.new("AU", nil, "Melbourne").to_s.should == "Melbourne AU"
  end
end
    