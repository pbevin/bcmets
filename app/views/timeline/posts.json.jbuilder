json.posts do |json|
  json.array!(@posts) do |post|
    json.extract! post, :id, :user_id, :name, :email, :subject
    json.avatar_url post.user && avatar_url(post.user, :small)
    json.user_path post.user && user_path(post.user)
    json.body to_html post.body_utf8
  end
end