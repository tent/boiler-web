//= require ./core
//= require ./static_config
//= require_self

(function () {

	if (!Boiler.config.JSON_CONFIG_URL) {
		throw Error("json_config_url is required!");
	}

	Boiler.fetchConfig = function (callback) {
		Marbles.HTTP({
			method: 'GET',
			url: Boiler.config.JSON_CONFIG_URL,
			middleware: [
				Marbles.HTTP.Middleware.WithCredentials,
				Marbles.HTTP.Middleware.SerializeJSON
			],
			callback: function (res, xhr) {
				if (xhr.status !== 200) {
					if (Boiler.config.SIGNIN_URL && xhr.status === 401) {
						Boiler.config.authenticated = false;
						Boiler.trigger('config:ready');
						if (typeof callback === 'function') {
							callback(Boiler.config);
						}
						return;
					} else {
						throw Error("failed to fetch json config: " + xhr.status + " - " + JSON.stringify(res));
					}
				} else {
					Boiler.config.authenticated = true;
				}

				for (var key in res) {
					Boiler.config[key] = res[key];
				}

				if (!Boiler.config.meta) {
					throw Error("invalid config! missing meta post: " + JSON.stringify(res));
				}

				Boiler.trigger('config:ready');
				if (typeof callback === 'function') {
					callback(Boiler.config);
				}
			}
		});
	};

})();
