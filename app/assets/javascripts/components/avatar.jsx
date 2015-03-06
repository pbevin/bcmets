//= require moment
//= require md5

(function() {
  var Avatar = React.createClass({
    render: function() {
      var article = this.props.article;
      var sender_path = "/archive/author?email=" + article.sender_email;
      var src = article.avatar_url || gravatarUrl(article.sender_email);
      return (
        <a href={sender_path} className="avatar">
          <img src={src} width={100} height={100} className="profile" />
        </a>
      );
    }
  });

  function gravatarUrl(email) {
    var hash;
    hash = CryptoJS.MD5(email.trim().toLowerCase()).toString();
    return "http://www.gravatar.com/avatar/" + hash + "?s=50&d=identicon";
  };

  window.Avatar = Avatar;
})();
