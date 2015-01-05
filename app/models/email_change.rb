class EmailChange
  include ActiveModel::Validations

  attr_accessor :new_email, :old_email

  validates :new_email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validate :has_changed

  def execute(current_user)
    SubscriberEvent.queue.notify_email_changed(old_email, new_email)
    current_user.update_attributes(email: new_email)
  end

  private

  def has_changed
    errors.add(:new_email, "cannot be the same as before") if new_email == old_email
  end
end
