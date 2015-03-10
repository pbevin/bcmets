//= require moment

var PureRenderMixin = React.addons.PureRenderMixin;

var Article = React.createClass({
  propTypes: {
    article: React.PropTypes.object.isRequired,
    signedIn: React.PropTypes.bool.isRequired,
    roots: React.PropTypes.array.isRequired
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    var article = this.props.article;

    return (
      <div id="article">
        <h1>{article.subject}</h1>
        <Header article={article} signedIn={this.props.signedIn} />
        <Body article={article} roots={this.props.roots} />
      </div>
    );
  }
});

var Header = React.createClass({
  propTypes: {
    article: React.PropTypes.object.isRequired,
    signedIn: React.PropTypes.bool.isRequired,
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    var article = this.props.article;
    var signedIn = this.props.signedIn;
    var star, reply;

    if (signedIn) {
      star = <Star article={this.props.article} />
    }

    if (isRecent(article.sent_at)) {
      var replyPath = "/article/" + article.id + "/reply";
      reply = <div id="reply_to"><a href={replyPath}>Reply to this message</a></div>;
    }

    return (
      <div id="header">
        {star}
        {reply}
        <ul id="headers">
          <li id="from">
            From: {linkToAuthor(article.sender_name, article.sender_email)}
          </li>
          <li id="date">Date: {dateAndTimeAgo(article.sent_at)}</li>
        </ul>
      </div>
    );
  }
});

var Star = React.createClass({
  propTypes: {
    article: React.PropTypes.object.isRequired,
  },

  render: function() {
    return (
      <div id="star">
        <a className="save_this" href="javascript:void(0)" onClick={this.toggleSave}>Save this message</a>
        &nbsp;
        <a className="star" href="javascript:void(0)" onClick={this.toggleSave} />
      </div>
    );
  }
});

var Body = React.createClass({
  propTypes: {
    article: React.PropTypes.object.isRequired,
    roots: React.PropTypes.array.isRequired
  },
  mixins : [],

  render: function() {
    article = this.props.article;
    return (
      <div id="body">
        <Avatar article={article} />
        <div dangerouslySetInnerHTML={{__html: article.body }} />
      </div>
    )
  }
});

function isRecent(date) {
  return moment(date).isAfter(moment().subtract(1, "month"));
}

function dateAndTimeAgo(sentAtDate) {
  var date = moment(sentAtDate);
  return humanDate(date) + " (" + timeAgo(date) + ")";
}

function humanDate(date) { // date is a moment
  var startOfToday = moment().startOf('day');
  if (date.isBefore(startOfToday)) {
    return date.format("MMM D, YYYY");
  } else {
    return date.format("hh:mm A");
  }
}

function timeAgo(date) { // date is a moment
  return date.fromNow();
}

function linkToAuthor(sender_name, sender_email) {
  var path = "/archive/author?email=" + sender_email;

  if (sender_name) {
    return <span>{sender_name} &lt;<a href={path}>{sender_email}</a>&gt;</span>;
  } else {
    return <span>&lt;<a href={path}>{sender_email}</a>&gt;</span>;
  }
}
