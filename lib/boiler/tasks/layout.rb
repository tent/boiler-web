require 'boiler/compiler'

namespace :layout do
  task :compile do
    Boiler::Compiler.compile_layouts
  end

  task :gzip do
    Boiler::Compiler.gzip_layouts
  end
end
