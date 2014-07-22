//= require ./mixins

(function () {

	var AuthRouter = Marbles.Router.createClass({
		displayName: 'Boiler.Routers.Auth',

		mixins: [Boiler.Routers.Mixins],

		routes: [
			{ path : "signin" , handler: "signin" }
		],

		signin: function (params) {
			this.resetScrollPosition.call(this);

			var queryParams = params[0];
			if (queryParams.redirect && queryParams.redirect.indexOf('//') !== -1 && queryParams.redirect.indexOf('//') < queryParams.redirect.indexOf('/')) {
				queryParams.redirect = null;
			}
			if (!queryParams.redirect) {
				queryParams.redirect = Boiler.config.PATH_PREFIX || '/';
			}

			function handleSignin() {
				Boiler.fetchConfig(function () {
					if (Boiler.config.authenticated) {
						Boiler.handleAuthenticated();
						Marbles.history.navigate(queryParams.redirect || '/');
					} else {
						Marbles.history.navigate(Marbles.history.path, { force: true, replace: true });
					}
				});
			}

			React.renderComponent(
				Boiler.Views.Auth({
					signinURL: Boiler.config.SIGNIN_URL,
					resetURL: Boiler.config.RESET_PASSPHRASE_URL,
					successHandler: handleSignin }),
				Boiler.config.container_el
			);
		}
	});

	Boiler.Routers = Boiler.Routers || {};
	Boiler.Routers.auth = new AuthRouter();

})();
