class SendArticle
  def initialize(responder)
    @responder = responder
  end

  def call(current_user, params)
    return @responder.spam if params[:body].present?
    params[:body] = params[:qt]

    article = Article.new(params)
    if article.valid?
      article.user = current_user || User.find_by_email(article.email)
      article.send_via_email

      parent_id = article.reply? ? article.parent_id : nil
      return @responder.sent(article, parent_id)
    else
      article.body = nil
      return @responder.invalid(article)
    end
  end
end
