require 'rails_helper'

describe EmailChange do
  describe '#valid?' do
    let(:email_change) { EmailChange.new }
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
end
