class Notifier < ActionMailer::Base
  default :from => "Pete Bevin <owner@bcmets.org>"

  def activation_instructions(user)
    @account_activation_url = register_url(user.perishable_token)
    mail(:subject => "Activation Instructions", :recipients => user.email)
  end

  def activation_confirmation(user)
    @root_url = root_url
    mail(:subject => "Activation Complete", :recipients => user.email)
  end

  def password_reset(user)
    @reset_password_url = user.perishable_token
    mail(:subject => "Password reset", :recipients => user.email)
  end

  def article(article)
    headers["In-Reply-To"] = article.parent_msgid
    headers["Return-Path"] = 'bcmets@bcmets.org'

    @article = article

    mail(
      :subject    => article.subject,
      :recipients => article.mail_to,
      :cc         => article.mail_cc,
      :from       => article.from
    )
  end
end
