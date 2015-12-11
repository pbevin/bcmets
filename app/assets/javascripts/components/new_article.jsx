(function() {
  "use strict";

  var node;

  function initNewArticleView() {
    node = $('[data-react-class]').get(0);

    initNewArticleStore(node);

    NewArticleStore.listen(updateView);
  }

  function updateView(props) {
    React.render(<NewArticle {...props} />, node);
    if (!props.form.ready) { Actions.formReady(); }
  }
  window.updateView = updateView;
  window.initNewArticleView = initNewArticleView;

  var NewArticle = React.createClass({
    propTypes: {
      article: React.PropTypes.object.isRequired,
      quoted: React.PropTypes.string,
      form: React.PropTypes.object.isRequired
    },
    getDefaultProps: function() {
      quoted: undefined
    },
    mixins : [ PureRenderMixin ],

    render: function() {
      var submitButton, quoteButton;
      var article = this.props.article;
      var form = this.props.form;
      var bodyFieldName = form.ready ? "article[qt]" : "article[body]";

      return (
        <Form data={form}>
          <fieldset>
            <ErrorMessages errors={article.error_messages} />
            <Field label="Name">
              <input
                type="text"
                name="article[name]"
                value={article.sender_name}
                onChange={this.updateArticle("sender_name")}
              />
            </Field>

            <Field label="Email">
              <input
                type="email"
                name="article[email]"
                value={article.sender_email}
                onChange={this.updateArticle("sender_email")}
                onBlur={this.checkEmail}
              />
              {this.emailSuggestion(article)}
            </Field>

            {this.replyFields(article)}

            <Field label="Subject">
              <input
                type="text"
                name="article[subject]"
                value={article.subject}
                onChange={this.updateArticle("subject")}
              />
            </Field>

            <Field label="Message:">
              <textarea
                name={bodyFieldName}
                value={article.body}
                onChange={this.updateArticle("body")}
                rows="15"
                cols="60"
              />
            </Field>

            <div>
              {this.submitButton(article)}
              {this.quoteButton(article)}
            </div>

          </fieldset>
        </Form>
      );
    },

    emailSuggestion: function(article) {
      if (!article.emailSuggestion) return null;
      return (
        <span className="email_suggestion">
          Did you mean
          {" "}
          <Link onClick={this.useSuggestion}>{article.emailSuggestion}</Link>?
        </span>
      );
    },

    replyFields: function(article) {
      if (!article.parent_id) return null;

      return (
        <Field label="Reply To:">
          <input type="hidden" name="article[parent_id]" value={article.parent_id} />
          <select name="article[reply_type]" value={article.reply_type} onChange={this.updateArticle("reply_type")}>
            <option value="list">List only</option>
            <option value="sender">Sender only</option>
            <option value="both">Both</option>
          </select>
        </Field>
      );
    },

    submitButton: function(article) {
      if (article.submitted) {
        return <button disabled>Sending...</button>;
      } else if (this.validForm()) {
        return <button onClick={this.post}>Post</button>;
      } else {
        return <button disabled>Post</button>;
      }
    },

    quoteButton: function(article) {
      if (article.quoted) {
        return (
          <div className="quote_lecture">
            Please trim the quoted text before posting.
          </div>
        );
      } else {
        return (
          <button type="button" className="quote" onClick={this.quote}>Quote</button>
        );
      }
    },

    updateArticle: function(name) {
      return function(e) {
        Actions.updateArticle(name, e.target.value);
      }
    },

    checkEmail: function() {
      Actions.checkEmail();
    },

    useSuggestion: function() {
      Actions.acceptEmailSuggestion();
    },

    quote: function() {
      Actions.quoteOriginal();
    },

    post: function() {
      Actions.submitForm();
    },

    validForm: function() {
      var article = this.props.article;
      return article.body != "" &&
        article.subject != "" &&
        article.sender_name != "" &&
        validEmail(article.sender_email)
    }
  });


  window.NewArticle = NewArticle;
})();
