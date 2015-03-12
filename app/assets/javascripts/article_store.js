//= require reflux.min

$(function() {
  var Actions = Reflux.createActions([
    "toggleSaved"
  ]);

  var ArticleStore = Reflux.createStore({
    listenables: Actions,

    init: function() {
      var node = $('[data-react-class]')[0];
      var propsJson = node.getAttribute('data-react-props');
      var props = propsJson && JSON.parse(propsJson);
      this.props = props;
    },

    onToggleSaved: function() {
      var id = this.props.article.id;
      var saved = !this.props.article.saved;
      var data = {
        saved: saved,
        authenticity_token: this.props.authToken
      };

      $.post("/articles/" + id + "/set_saved", data).done(function(response) {
        this.props = React.addons.update(this.props, {
          article: {
            saved: { $set: response.saved }
          }
        });
        this.trigger(this.props);
      }.bind(this));
    }
  });

  window.ArticleStore = ArticleStore;
  window.Actions = Actions;
});
