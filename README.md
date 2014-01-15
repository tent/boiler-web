# Boiler

## Setup

### Config

ENV                    | Required | Description
---------------------- | -------- | -----------
`NAME`                 | Required | Name of app (used as the title for the main layout and as the app name when authenticating with Tent).
`URL`                  | Required | URL the app is mounted at.
`JSON_CONFIG_URL`      | Required | URL of the JSON config. The `Access-Control-Allow-Credentials` header must be set. Must return a 401 status if auth required via `SIGNIN_URL`.
`GLOBAL_NAV_CONFIG`    | Required | Filesystem path to JSON file containing the global nav config as described below.
`NAV_CONFIG`					 | Required | Filesystem path to JSON file containing the app nav config as described below.
`PATH_PREFIX`          | Optional | If the app is not mounted at the domain root, you need to specify the path prefix.
`ASSETS_DIR`           | Optional | Directory assets should be compiled to (defaults to `public/assets`).
`ASSET_ROOT`           | Optional | URL prefix of where assets are located (defaults to `/assets`, e.g. an asset named `foo` would be found at `/assets/foo`).
`ASSET_CACHE_DIR`      | Optional | Filesystem path used by Sprockets to cache compiled assets.
`APP_ASSET_MANIFEST`   | Optional | Filesystem path to manifest.json.
`SENTRY_URL`           | Optional | Set if you want to track errors with [Sentry](https://www.getsentry.com).
`SKIP_AUTHENTICATION`  | Optional | Set if you're using the dev app but using another server for auth / serving `config.json`.
`SIGNOUT_URL`          | Optional | URL where sign-out action is located. Defaults to `/signout`.
`SIGNOUT_REDIRECT_URL` | Optional | URL to redirect to after signing out.
`SIGNIN_URL`           | Optional | URL accepting a POST request with form encoded `username` and `passphrase` to authorize `config.json`.

All ENV vars must be set at compile time and when running the ruby app (for development purposes only).

#### JSON config

The app requires a JSON config as shown below.

```json
{
  "credentials": {
    "id": "...",
    "hawk_key": "...",
    "hawk_algorithm": "..."
  },
  "meta": {
    "content": {
      "entity": "...",
      "profile": {},
      "servers": [
        {
          "version": "0.3",
          "preference": 0,
          "urls": {
            "oauth_auth": "...",
            "oauth_token": "...",
            "posts_feed": "...",
            "post": "...",
            "new_post": "...",
            "post_attachment": "...",
            "attachment": "...",
            "batch": "...",
            "server_info": "...",
            "discover": "..."
          }
        }
      ]
    },
    "entity": "...",
    "id": "...",
    "published_at": ...,
    "type": "https://tent.io/types/meta/v0#",
    "version": {
      "id": "...",
      "published_at": ...
    }
  }
}
```

#### Global nav config

`GLOBAL_NAV_CONFIG` must point to a JSON file with the following format:

```json
{
	"items": [
		{ "name": "MyApp", "iconClassName": "fa fa-globe", "url": "http://localhost:9292", "selected": true }
	]
}
```

#### Nav config

`NAV_CONFIG` must point to a JSON file with the following format:

```json
{
	"items": [
		{ "name": "Settings", "iconClassName": "fa fa-gears", "path": "/settings" }
	]
}
```

Note that the `path` of each item excludes the `PATH_PREFIX`.

## Usage

Copy the `Gemfile` into your project root and modify as needed.

Also in your project root, create a `config.ru`:

```ruby
require 'bundler'
Bundler.require

$stdout.sync = true

require 'boiler'

map '/' do
  use Rack::Session::Cookie,  :key => 'myapp.session',
                              :expire_after => 2592000, # 1 month
                              :secret => ENV['SESSION_SECRET'] || SecureRandom.hex
  run Boiler.new({
		:asset_names => %w(
			application.css
			application.js
		),
		:layouts => {
      :application => '*'
    }
	})
end
```

and a `Rakefile`:

```ruby
require 'bundler/setup'

require 'boiler'

require 'boiler/tasks/assets'
require 'boiler/tasks/layout'

task :configure do
  Boiler.configure({
		:asset_names => %w(
			application.css
			application.js
		),
		:layouts => {
      :application => '*'
    }
	})
end

task :compile => ['configure', 'assets:precompile', 'layout:compile'] do
end
```

Look in `lib/boiler.rb` for a full list of configuration.

Now you're ready to run the development app with `bundle exec puma` and
compile the static components with `bundle exec rake compile`. (Ensure that
any needed ENV variables are set when running either of those.)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
