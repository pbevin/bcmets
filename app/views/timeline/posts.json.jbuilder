json.posts do |json|
  json.array!(@posts) do |post|
    json.extract! post, :id, :user_id, :name, :email, :subject
    json.date post.received_at
    json.avatar_url post.user && avatar_url(post.user, :small)
    json.user_path post.user ? user_path(post.user) : author_search_path(email: post.email)
    json.body to_html(post.body_utf8)
  end
end
