require 'mailbox'

describe Mailbox do
  let(:mailbox) { Mailbox.new(filename) }

  context "A Non-UTF8 message" do
    let(:filename) { "spec/data/mailbox/nonutf" }

    it "has binary encoding" do
      message = mailbox.first
      message.should_not be_nil
      message.encoding.name.should == "ASCII-8BIT"
    end
  end
end

