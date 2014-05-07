//= require tent-client
//= require ./boiler/core
//= require ./boiler/config
//= require_self
//= require_tree ./boiler/props
//= require_tree ./boiler/routers
//= require_tree ./boiler/views
//= require_tree ./boiler/collections
//= ./boiler/raven_config

(function () {

	Marbles.Utils.extend(Boiler, Marbles.Events, Marbles.Accessors, {
		Views: {},
		Models: {},
		Collections: {},
		Routers: {},
		Props: {},
		Helpers: {

			formatRelativeTime: function (milliseconds) {
				var time = moment(milliseconds);
				return time.fromNow();
			},

			formatDateTime: function (milliseconds) {
				var time = moment(milliseconds);
				return time.format();
			},

			fullPath: function (path) {
				prefix = Boiler.config.PATH_PREFIX || '/';
				return (prefix + '/').replace(/\/+$/, '') + path;
			}

		},

		run: function (options) {
			if (!Marbles.history || Marbles.history.started) {
				return;
			}

			if (!options) {
				options = {};
			}

			if (!this.config.container_el) {
				this.config.container_el = options.container_el || document.getElementById('main');
			}

			if (this.config.authenticated) {
				this.handleAuthenticated();
			}

			this.initAppNav();
			this.initAuthButton();

			Marbles.history.start(Marbles.Utils.extend({ root: (this.config.PATH_PREFIX || '') + '/', silent: true }, options.history || {}));

			if (this.config.authenticated || Marbles.history.path.match(/^[^a-z]*signin[^a-z]/)) {
				Marbles.history.loadURL();
			} else {
				Marbles.history.navigate(this.Helpers.fullPath('/signin'+ (Marbles.history.path ? '?redirect='+ Marbles.history.path : '')), { replace: true });
			}

			this.ready = true;
			this.trigger('ready');
		},

		handleAuthenticated: function () {
			this.set('current_entity', this.config.meta.content.entity);
			this.set('client', new TentClient(this.current_entity, {
				serverMetaPost: this.config.meta,
				credentials: this.config.credentials
			}));
			this.trigger('change:authenticated', true);
		},

		handleUnauthenticated: function () {
			this.set('current_entity', null);
			this.set('client', null);
			this.trigger('change:authenticated', false);
		},

		initAppNav: function () {
			var appNav = React.renderComponent(
				Boiler.Views.AppNav({
					authenticated: this.config.authenticated,
					navItems: this.config.nav.items,
				}),
				document.getElementById('main-nav')
			);

			this.on('change:authenticated', function (authenticated) {
				appNav.setProps({ authenticated: authenticated });
			});

			Marbles.history.on("handler:before", function (handler, path, params) {
				appNav.setState({
					activePath: path
				});
			});
		},

		initAuthButton: function () {
			if (!Boiler.config.SIGNOUT_URL) {
				return;
			}

			var el = document.getElementById('auth-button');

			if (!el) {
				return;
			}

			var authBtn = React.renderComponent(
				Boiler.Views.AuthButton({
					authenticated: this.config.authenticated,
					onClick: this.performSignout
				}),
				el
			);

			this.on('change:authenticated', function (authenticated) {
				authBtn.setProps({ authenticated: authenticated });
			});
		},

		performSignout: function () {
			Marbles.HTTP({
				method: 'POST',
				url: Boiler.config.SIGNOUT_URL,
				middleware: [Marbles.HTTP.Middleware.WithCredentials],
				callback: Boiler.signoutHandler || Boiler.performSignoutRedirect
			});
		},

		performSignoutRedirect: function () {
			window.location.href = Boiler.config.SIGNOUT_REDIRECT_URL;
		}
	});

	if (Boiler.config_ready) {
		Boiler.trigger('config:ready');
	}

})();
