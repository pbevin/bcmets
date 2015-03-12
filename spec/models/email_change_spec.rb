require 'rails_helper'

describe EmailChange do
  let(:queue) { instance_spy(SubscriberEvent::Queue) }
  before(:each) do
    SubscriberEvent.queue = queue
  end

  describe '#valid?' do
    it "checks the new email address" do
      expect(EmailChange.new(new_email: "test@example.com")) .to be_valid
      email_change = EmailChange.new(new_email: "@example.com")
      expect(email_change).not_to be_valid
      expect(email_change.errors.full_messages).to eq(["New email is invalid"])
    end

    it "doesn't allow old and new addresses to be the same" do
      email_change = EmailChange.new(new_email: "test@example.com", old_email: "test@example.com")
      expect(email_change).not_to be_valid
      expect(email_change.errors.full_messages).to eq(["New email cannot be the same as before"])
    end
  end

  describe '#execute' do
    it "sends a notification to the subscriber event queue" do
      email_change = EmailChange.new(old_email: "test@example.com", new_email: "test@example.net")

      user = instance_spy(User)

      email_change.execute(user)

      expect(queue).to have_received(:notify_email_changed)
        .with("test@example.com", "test@example.net")
    end
  end
end
