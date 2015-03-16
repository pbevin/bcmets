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
      body: article.body && to_html(article.body_utf8),
      saved: article.saved_by?(current_user),
      avatar_url: profile_picture_url(article.user),
      sender_name: article.name,
      sender_email: article.email,
      sent_at: article.sent_at
    }
  end

  def article_view_data
    {
      article: article_to_api_data(@article),
      roots: threaded_roots(@conversation_roots),
      signedIn: !!current_user,
      authToken: form_authenticity_token
    }
  end

  def threaded_roots(roots)
    roots.map { |article|
      {
        id: article.id,
        subject: article.subject,
        sender_name: article.name,
        sender_email: article.email,
        sent_at: article.sent_at,
        children: threaded_roots(article.children || [])
      }
    }
  end

  def new_article_props(article, quoted)
    return {
      article: {
        id: article.id,
        subject: article.subject,
        replying: !!quoted,
        reply_type: "list",
        parent_id: article.parent_id,
        sender_name: article.name,
        sender_email: article.email,
        body: "",
        sent_at: article.sent_at
      }.merge(error_props(article)),
      quoted: quoted,
      form: form_props(articles_path)
    }
  end

  def form_props(submit_path)
    {
      action: submit_path,
      csrf_param: request_forgery_protection_token,
      csrf_token: form_authenticity_token
    }
  end

  def error_props(obj)
    return {} if obj.errors.none?
    return {
      error_messages: obj.errors.full_messages,
      errors: obj.errors.to_hash
    }
  end
end
