var Link = React.createClass({
  propTypes: {
    onClick: React.PropTypes.func.isRequired
  },
  mixins : [ PureRenderMixin ],

  render: function() {
    return (
      <a href="javascript:void(0)" onClick={this.props.onClick}>
        {this.props.children}
      </a>
    );
  }
});
