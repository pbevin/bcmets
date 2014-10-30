{div, h2, a, img, strong} = React.DOM

Timeline = React.createClass
  displayName: "Timeline",
  render: ->
    div({ className: "tl" }, PostList({ posts: this.props.posts }))

PostList = React.createClass
  displayName: "PostList",
  render: ->
    div { className: "tl_posts" },
      this.props.posts.map (post) -> Post({ post: post })

Post = React.createClass
  displayName: "Post",
  render: ->
    post = this.props.post
    div { className: "tl_post" },
      PostHeader(post: post),
      PostBody(post: post),

PostHeader = React.createClass
  displayName: "PostHeader",
  render: ->
    post = this.props.post
    div { className: "tl_headers" },
      div { className: "tl_header" }, "From: ", a({ href: post.user_path }, post.name),
      div { className: "tl_header" }, "Subject: ", post.subject

PostBody = React.createClass
  displayName: "PostBody",
  render: ->
    post = this.props.post
    div { className: "tl_body" },
      Avatar(post: post),
      div dangerouslySetInnerHTML: { __html: post.body }

Avatar = React.createClass
  displayName: "Avatar",
  render: ->
    post = this.props.post
    a { href: post.user_path, className: "avatar" },
      img { src: post.avatar_url, width: 100, height: 100 }

window.Timeline = Timeline

