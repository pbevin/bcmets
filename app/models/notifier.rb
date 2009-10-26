class Notifier < ActionMailer::Base
  def activation_instructions(user)
    subject       "Activation Instructions"
    from          "Pete Bevin <owner@bcmets.org>"
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    subject       "Activation Complete"
    from          "Pete Bevin <owner@bcmets.org>"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end
  
  def password_reset(user)
    subject       "Password reset"
    from          "Pete Bevin <owner@bcmets.org>"
    recipients    user.email
    sent_on       Time.now
    body          :reset_url => reset_password_url(user.perishable_token)
  end
end
