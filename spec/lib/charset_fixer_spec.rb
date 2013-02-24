# Encoding: UTF-8

require 'charset_fixer'

describe CharsetFixer do
  it "does nothing to fix a UTF-8 string" do
    CharsetFixer.new("utf-8").fix("daïs").should == "daïs"
  end

  it "fixes an ISO8859-1 string wrongly encoded as UTF-8" do
    bad_string = "daïs".encode("iso8859-1").force_encoding("utf-8")
    CharsetFixer.new("iso8859-1").fix(bad_string).bytes.to_a.
      should == "daïs".bytes.to_a
  end

  it "doesn't crash when given a stupid encoding name" do
    CharsetFixer.new("no-such-encoding").fix("daïs").should == "daïs"
  end

  it "switches to iso8859-1 when the stated charset causes problems" do
    # Article 106667 has a \x9d character
    CharsetFixer.new("Windows-1252").fix("\x9d").encode("utf-8").should == "\u009d"
  end

  it "ignores ConverterNotFound errors" do
    CharsetFixer.new("utf-7").fix("hello").should == "hello"
  end
end

