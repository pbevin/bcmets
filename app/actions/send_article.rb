class SendArticle
  def initialize(responder)
    @responder = responder
  end

  def call(current_user, params)
    return @responder.spam if params[:body].present?
    params[:body] = params[:qt]

    article = Article.new(params)
    if article.valid?
      if article.parent_id
        parent = article.parent
        article.to = parent.email
        article.parent_msgid = parent.msgid
      end

      article.user = current_user || User.find_by_email(article.email)
      article.send_via_email

      return @responder.sent(article, article.parent_id)
    else
      article.body = nil
      return @responder.invalid(article)
    end
  end
end
