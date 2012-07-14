module ArticlesHelper
  def show_star(article)
    if current_user.saved?(article)
      "selected"
    else
      ""
    end
  end
end
