/** @jsx React.DOM */

Boiler.Views.AuthButton = React.createClass({
	displayName: 'Boiler.Views.AuthButton',

	handleClick: function (e) {
		e.preventDefault();

		if (this.props.authenticated) {
			this.props.onClick();
		}
	},

	render: function () {
		return (
      <div className='nav-icon app-icon-signout icon-2x' onClick={this.handleClick} title={(this.props.authenticated ? 'Sign out' : 'Sign in')}></div>
		);
	}
});
