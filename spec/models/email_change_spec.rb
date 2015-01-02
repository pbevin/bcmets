require 'rails_helper'

describe EmailChange do
  let(:email_change) { EmailChange.new }
  let(:queue) { instance_spy(SubscriberEvent::Queue) }
  before(:each) do
    SubscriberEvent.queue = queue
  end

  describe '#valid?' do
    it "checks the new email address" do
      email_change.new_email = "test@example.com"
      email_change.should be_valid

      email_change.new_email = "@example.com"
      email_change.should_not be_valid
      email_change.errors.full_messages.should == ["New email is invalid"]
    end

    it "doesn't allow old and new addresses to be the same" do
      email_change.old_email = "test@example.com"
      email_change.new_email = "test@example.com"
      email_change.should_not be_valid

      email_change.errors.full_messages.should == ["New email cannot be the same as before"]
    end
  end

  describe '#execute' do
    it "sends a notification to the subscriber event queue" do
      email_change.old_email = "test@example.com"
      email_change.new_email = "test@example.net"

      user = instance_spy(User)

      email_change.execute(user)

      expect(queue).to have_received(:notify_email_changed)
        .with("test@example.com", "test@example.net")
    end
  end
end
