module ArticlesHelper
  def show_star(article)
    if article.saved_by?(current_user)
      "selected"
    else
      ""
    end
  end

  def article_to_api_data(article)
    return {
      id: article.id,
      subject: article.subject,
      body: to_html(article.body_utf8),
      starred: article.saved_by?(current_user),
      avatar_url: profile_picture_url(article.user),
      sender_name: article.name,
      sender_email: article.email,
      sent_at: article.sent_at
    }
  end

  def article_view_data
    {
      article: article_to_api_data(@article),
      roots: @conversation_roots,
      signedIn: !!current_user,
      authToken: form_authenticity_token
    }
  end
end
