var Form = React.createClass({
  propTypes: {
    data: React.PropTypes.object.isRequired
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    var { data, ...other } = this.props;

    return (
      <form {...other} action={data.action} method="POST">
        <input type="hidden" name={data.csrf_param} value={data.csrf_token} />
        {this.props.children}
      </form>
    );
  }
});

var Field = React.createClass({
  propTypes: {
    label: React.PropTypes.string.isRequired
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    return (
      <label>
        <div>{this.props.label}</div>
        {this.props.children}
      </label>
    );
  }
});
