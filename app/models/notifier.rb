class Notifier < ActionMailer::Base
  def common(user)
    from          "Pete Bevin <owner@bcmets.org>"
    recipients    user.email
    sent_on       Time.now
  end

  def activation_instructions(user)
    common(user)
    subject       "Activation Instructions"
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    common(user)
    subject       "Activation Complete"
    body          :root_url => root_url
  end

  def password_reset(user)
    common(user)
    subject       "Password reset"
    body          :reset_url => reset_password_url(user.perishable_token)
  end

  def article(article)
    subject    article.subject
    recipients article.mail_to
    cc         article.mail_cc
    from       article.from

    headers["In-Reply-To"] = article.parent_msgid
    headers["Return-Path"] = 'bcmets@bcmets.org'

    body       :article => article
  end
end
