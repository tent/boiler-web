require 'boiler/compiler'

namespace :assets do
  task :compile do
    Boiler::Compiler.compile_assets
  end

  task :gzip do
    Boiler::Compiler.gzip_assets
  end

  # compile assets when deploying to heroku
  task :precompile => :gzip
end
