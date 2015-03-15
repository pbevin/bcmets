//= require reflux.min

function initNewArticleStore(node) {
  var Actions = Reflux.createActions([
    "updateArticle",
    "quoteOriginal",
    "formReady", // spam honey trap
    "submitForm",
    "checkEmail",
    "acceptEmailSuggestion"
  ]);

  Actions.updateArticle.sync = true;

  var NewArticleStore = Reflux.createStore({
    listenables: Actions,

    init: function() {
      var propsJson = node.getAttribute('data-react-props');
      var props = propsJson && JSON.parse(propsJson);
      props.article.emailSuggestion = findHint(props.article.sender_email);
      this.props = Immutable.fromJS(props);
    },

    onUpdateArticle: function(name, value) {
      this.updateArticle(name, value);
      this.publish();
    },

    checkEmail: function() {
      var hint = findHint(this.articleAttribute("sender_email"));

      this.updateArticle("emailSuggestion", hint);
      this.publish();
    },

    acceptEmailSuggestion: function() {
      this.bulkUpdateArticle({
        sender_email: this.articleAttribute("emailSuggestion"),
        emailSuggestion: null
      });
      this.publish();
    },

    quoteOriginal: function() {
      this.bulkUpdateArticle({
        body: this.articleAttribute("body") + "\n\n" + this.quotedText(),
        quoted: true
      });
      this.publish();
    },

    submitForm: function() {
      this.updateArticle("submitted", true);
      this.publish();
    },

    formReady: function() {
      this.props = this.props.setIn(["form", "ready"], "1");
      this.publish();
    },

    quotedText: function() {
      return this.props.get("quoted").replace(/^/mg, "> ");
    },

    updateArticle: function(name, value) {
      this.props = this.props.setIn(["article", name], value);
    },

    bulkUpdateArticle: function(attrs) {
      this.props = this.props.mergeDeep({ article: attrs });
    },

    articleAttribute: function(name) {
      return this.props.getIn(["article", name]);
    },

    publish: function() {
      // this.trigger(this.props.toJS());
      updateView(this.props.toJS());
    }
  });

  function findHint(email) {
    var hint;

    Mailcheck.run({
      email: email,
      suggested: function(suggestion) { hint = suggestion.full; },
      empty: function() { hint = null; }
    });

    return hint;
  }


  window.NewArticleStore = NewArticleStore;
  window.Actions = Actions;
}
