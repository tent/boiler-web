require 'boiler/version'
require 'yajl'
require 'erb'

require 'icing/compiler'
require 'marbles-js/compiler'

module Boiler
  ConfigurationError = Class.new(StandardError)

  def self.settings
    @settings ||= {}
  end

  def self.erb(path)
    template = ERB.new(File.read(path))
    template.result(self.class_eval { binding })
  end

  def self.configure(options = {})
    ##
    # App registration settings
    options[:tent_app] ||= {}
    self.settings[:name]        = options[:tent_app][:name]        || ENV['APP_NAME']
    self.settings[:description] = options[:tent_app][:description] || ENV['APP_DESCRIPTION']
    self.settings[:display_url] = options[:tent_app][:display_url] || ENV['APP_DISPLAY_URL']
    self.settings[:read_types]  = options[:tent_app][:read_types]
    self.settings[:write_types] = options[:tent_app][:write_types]
    self.settings[:scopes]      = options[:tent_app][:scopes]

    ##
    # Sentry settings
    self.settings[:sentry_url] = options[:sentry_url] || ENV['SENTRY_URL']

    ##
    # App settings
    self.settings[:url] = options[:url] || ENV['URL']
    unless settings[:url]
      raise ConfigurationError.new('Missing url option, you need to set URL')
    end
    self.settings[:path_prefix]          = options[:path_prefix]          || ENV['PATH_PREFIX']
    self.settings[:assets_dir]           = options[:assets_dir]           || ENV['ASSETS_DIR'] || File.expand_path('../../public/assets', __FILE__) # lib/../public/assets
    self.settings[:asset_root]           = options[:asset_root]           || ENV['ASSET_ROOT'] || '/assets'
    self.settings[:asset_cache_dir]      = options[:asset_cache_dir]      || ENV['ASSET_CACHE_DIR']
    self.settings[:json_config_url]      = options[:json_config_url]      || ENV['JSON_CONFIG_URL']
    self.settings[:signin_url]           = options[:signin_url]           || ENV['SIGNIN_URL']
    self.settings[:signout_url]          = options[:signout_url]          || ENV['SIGNOUT_URL']
    self.settings[:signout_redirect_url] = options[:signout_redirect_url] || ENV['SIGNOUT_REDIRECT_URL']

    self.settings[:vendor_asset_root] = File.expand_path('../../vendor/assets', __FILE__) # vendor/assets
    self.settings[:lib_asset_root] = File.expand_path('../assets', __FILE__) # lib/assets
    self.settings[:lib_view_root] = File.expand_path('../views', __FILE__) # lib/views

    self.settings[:asset_roots] = options[:asset_roots].to_a | [self.settings[:lib_asset_root]] | [self.settings[:vendor_asset_root]]
    self.settings[:view_roots] = options[:layout_roots].to_a | [self.settings[:lib_view_root]]

    self.settings[:asset_names] = [
      self.settings[:lib_asset_root],
      self.settings[:vendor_asset_root]
    ].inject(options[:asset_names].to_a) do |names, root|
      names | Dir[File.join(root, '*/*.*')].map { |path| path.split('/').last }
    end | Icing::Compiler::ASSET_NAMES | MarblesJS::Compiler::ASSET_NAMES | MarblesJS::Compiler::VENDOR_ASSET_NAMES

    if self.settings[:sentry_url]
      self.settings[:asset_names].push('raven.js')
    end

    self.settings[:layout_dir] = File.expand_path(File.join(self.settings[:assets_dir]))

    self.settings[:layouts] = options[:layouts] || [{
      :name => :application,
      :route => '/*'
    }]

    self.settings[:asset_manifest_path] = options[:asset_manifest_path] || ENV['APP_ASSET_MANIFEST']
    if self.settings[:asset_manifest_path] && File.exists?(self.settings[:asset_manifest_path])
      self.settings[:asset_manifest] = Yajl::Parser.parse(File.read(self.settings[:asset_manifest_path]))
    end

    self.settings[:global_nav_config_path] = options[:global_nav_config_path] || ENV['GLOBAL_NAV_CONFIG']
    if self.settings[:global_nav_config_path] && File.exists?(self.settings[:global_nav_config_path])
      self.settings[:global_nav_config] = Yajl::Parser.parse(erb(self.settings[:global_nav_config_path]))
    end
    self.settings[:global_nav_config] ||= {}
    self.settings[:global_nav_config]['items'] ||= []

    self.settings[:nav_config_path] = options[:nav_config_path] || ENV['NAV_CONFIG']
    if self.settings[:nav_config_path] && File.exists?(self.settings[:nav_config_path])
      self.settings[:nav_config] = Yajl::Parser.parse(erb(self.settings[:nav_config_path]))
    end
    self.settings[:nav_config] ||= {}
    self.settings[:nav_config]['items'] ||= []

    self.settings[:js_config] = options[:js_config] || {}

    # Default config.json url
    self.settings[:json_config_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/auth/config.json"

    # bypass oauth when true
    self.settings[:skip_authentication] = (options[:skip_authentication] == true) || (ENV['SKIP_AUTHENTICATION'] == 'true')

    # App registration, oauth callback uri
    self.settings[:redirect_uri] = "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/auth/tent/callback"

    # Default signout url
    self.settings[:signout_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/auth/signout"

    # Default signout redirect url
    self.settings[:signout_redirect_url] ||= self.settings[:url].to_s.sub(%r{/?\Z}, '/')
  end

  def self.new(options = {})
    self.configure(options)

    require 'boiler/app'

    unless self.settings[:skip_authentication]
      self.settings[:db_path] ||= options[:db_path]

      require 'boiler/model'
      Model.new
    end

    App.new
  end
end
