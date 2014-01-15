/** @jsx React.DOM */

(function () {

	Boiler.Views.AppNav = React.createClass({
		displayName: 'Boiler.Views.AppNav',

		getInitialState: function () {
			return {
				activeFragment: null,
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
				return <AppNavItem key={item.fragment} fragment={item.fragment} active={item.fragment === this.state.activeFragment} iconClassName={item.iconClassName} name={item.name} />;
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
		fragmentPath: function (fragment) {
			return Boiler.Helpers.fullPath('/' + fragment);
		},

		handleClick: function (e) {
			e.preventDefault();
			if (this.props.authenticated) {
				Marbles.history.navigate(this.props.fragment, { trigger: true });
			}
		},

		render: function () {
			return (
				<a className={(this.props.active ? 'active' : '') + (this.props.authenticated ? '' : ' disabled') } href={this.fragmentPath(this.props.fragment)} onClick={this.handleClick}>
					<li>
						<i className={this.props.iconClassName}></i>{this.props.name}
					</li>
				</a>
			);
		}
	});

})();
