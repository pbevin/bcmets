//= require moment
//= require md5

function fuzzyTime(time) {
  var diff, now, tm;
  tm = moment(time);
  now = moment();
  diff = Math.abs(now.diff(tm, 'hours'));
  if (diff < 6) {
    return tm.fromNow();
  } else if (diff < 3 * 24) {
    return tm.format('ddd, h:mma');
  } else if (diff < 7 * 24) {
    return tm.format('ddd Do, h:mma');
  } else {
    return tm.format('h:mma MMM D, YYYY');
  }
};

function gravatarUrl(email) {
  var hash;
  hash = CryptoJS.MD5(email.trim().toLowerCase()).toString();
  return "http://www.gravatar.com/avatar/" + hash + "?s=50&d=identicon";
};

var Timeline = React.createClass({
  render: function() {
    return <div className="tl"><PostList posts={this.props.posts} /></div>
  }
});

var PostList = React.createClass({
  render: function() {
    var posts = this.props.posts.map(function(post) {
      return <Post post={post} key={post.id} />;
    });
    return <div className="tl_posts">{posts}</div>;
  }
});

var Post = React.createClass({
  render: function() {
    var post = this.props.post;
    return <div className="tl_post"><PostHeader post={post} /><PostBody post={post} /></div>
  }
});

var PostHeader = React.createClass({
  render: function() {
    var post = this.props.post;
    return (
      <div className="tl_headers">
        <Avatar post={post} />
        <h2>{post.subject}</h2>
        <div className="tl_header">From: <a href={post.user_path}>{post.name}</a> {fuzzyTime(post.date)}</div>
        <div className="clr"/>
      </div>
    );
  }
});

var PostBody = React.createClass({
  render: function() {
    var post = this.props.post;
    return (
      <div className="tl_body">
        <div dangerouslySetInnerHTML={{__html: post.body }} />
      </div>
    );
  }
});

var Avatar = React.createClass({
  render: function() {
    var post = this.props.post;
    var src = post.avatar_url || gravatarUrl(post.email);
    return (
      <a href={post.user_path} className="tl_avatar">
        <img src={src} width={50} height={50} />
      </a>
    );
  }
});
