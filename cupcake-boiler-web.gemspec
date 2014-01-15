# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boiler/version'

Gem::Specification.new do |gem|
  gem.name          = "cupcake-boiler-web"
  gem.version       = Boiler::VERSION
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jesse@jessestuart.ca"]
  gem.description   = %(Boilerplate code for Cupcake apps. See README for details.)
  gem.summary       = %(Boilerplate code for Cupcake apps.)
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_runtime_dependency 'rack-putty'

  gem.add_runtime_dependency 'tent-client'
  gem.add_runtime_dependency 'omniauth-tent'

  gem.add_runtime_dependency 'yajl-ruby'
  gem.add_runtime_dependency 'mimetype-fu'
  gem.add_runtime_dependency 'sprockets', '~> 2.0'
  gem.add_runtime_dependency 'tilt', '~> 1.4.0'
  gem.add_runtime_dependency 'sass'
  gem.add_runtime_dependency 'coffee-script'
  gem.add_runtime_dependency 'marbles-js'
  gem.add_runtime_dependency 'marbles-tent-client-js'
  gem.add_runtime_dependency 'icing'
  gem.add_runtime_dependency 'react-jsx-sprockets'
  gem.add_runtime_dependency 'raven-js'
end
