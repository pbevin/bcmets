module ArticlesHelper
  def show_star(article)
    if article.saved_by?(current_user)
      "selected"
    else
      ""
    end
  end
end
