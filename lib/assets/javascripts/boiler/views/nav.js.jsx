/** @jsx React.DOM */

(function () {

	Boiler.Views.AppNav = React.createClass({
		displayName: 'Boiler.Views.AppNav',

		getInitialState: function () {
			return {
				activePath: null,
				menuActive: false
			};
		},

		handleMenuToggleClick: function (e) {
			e.preventDefault();
			this.setState({ menuActive: !this.state.menuActive });
		},

		render: function () {
			var AppNavItem = Boiler.Views.AppNavItem;
			var navItems = this.props.navItems.map(function (item) {
				return <AppNavItem key={item.path} path={item.path} active={item.path === this.state.activepath} iconClassName={item.iconClassName} name={item.name} />;
			}.bind(this));
			return (
				<div>
					<a className="menu-switch js-menu-switch" onClick={this.handleMenuToggleClick}>Menu</a>
					<ul className={"unstyled app-nav-list"+ (this.state.menuActive ? ' show' : '')}>
						{navItems}
					</ul>
				</div>
			);
		}
	});

	Boiler.Views.AppNavItem = React.createClass({
		pathPath: function (path) {
			return Boiler.Helpers.fullPath('/' + path);
		},

		handleClick: function (e) {
			e.preventDefault();
			if (this.props.authenticated) {
				Marbles.history.navigate(this.props.path, { trigger: true });
			}
		},

		render: function () {
			return (
				<a className={(this.props.active ? 'active' : '') + (this.props.authenticated ? '' : ' disabled') } href={this.pathPath(this.props.path)} onClick={this.handleClick}>
					<li>
						<i className={this.props.iconClassName}></i>{this.props.name}
					</li>
				</a>
			);
		}
	});

})();
