(function() {
  var Signin = React.createClass({
    getInitialState: function() {
      return {
        email: this.props.user_session.email || "",
        password: this.props.user_session.password || ""
      }
    },

    propTypes: {
      user_session: React.PropTypes.object.isRequired,
      form: React.PropTypes.object.isRequired
    },
    mixins : [ PureRenderMixin ],

    render: function() {
      return (
        <Form data={this.props.form} id="signin">
          <ErrorMessages errors={this.props.user_session.error_messages} />

          <Field label="Email">
            <input type="email" name="user_session[email]" placeholder="Your email address" value={this.state.email} onChange={this.emailChanged} autoFocus="true" />
          </Field>

          <Field label="Password">
            <input type="password" name="user_session[password]" placeholder="Your bcmets.org password" onChange={this.passwordChanged} value={this.state.password} />
          </Field>

          <p>{this.signinButton()}</p>

          <a href="/users/password">Forgot your password?</a>
        </Form>
      );
    },

    signinButton: function() {
      if (this.isValid()) {
        return <button>Sign In</button>;
      } else {
        return <button disabled>Sign In</button>;
      }
    },

    isValid: function() {
      var email = this.state.email;
      var password = this.state.password;

      return email && password && password.length > 0 && validEmail(email);
    },

    emailChanged: function(e) {
      this.setState({ email: e.target.value });
    },

    passwordChanged: function(e) {
      this.setState({ password: e.target.value });
    }
  });

  window.Signin = Signin

})();

