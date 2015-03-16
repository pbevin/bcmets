var ErrorMessages = React.createClass({
  propTypes: {
    errors: React.PropTypes.arrayOf(React.PropTypes.string.isRequired)
  },
  getDefaultProps: function() {
    errors: null
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    var errors = this.props.errors;
    if (!errors) return null;

    var items = errors.map(function(item, i) {
      return <li key={i}>{item}</li>;
    });

    return (
      <div className="errorExplanation">
        <h2>{pluralize(items.length, "error")} prohibited this article from being saved</h2>
        <p>There were problems with the following fields:</p>
        <ul>{items}</ul>
      </div>
    );
  }
});
