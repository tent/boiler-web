require 'boiler'

module Boiler
  module Compiler
    extend self

    attr_accessor :sprockets_environment

    def configure_sprockets(options = {})
      # Setup Sprockets Environment
      require 'rack-putty'
      require 'boiler/app/middleware'
      require 'boiler/app/asset_server'

      Boiler::App::AssetServer.logfile = STDOUT

      self.sprockets_environment = Boiler::App::AssetServer.sprockets_environment

      if options[:compress]
        # Setup asset compression
        require 'uglifier'
        require 'sprockets-rainpress'
        sprockets_environment.js_compressor = Uglifier.new
        sprockets_environment.css_compressor = Sprockets::Rainpress
      end
    end

    def assets_dir
      @assets_dir ||= Boiler.settings[:assets_dir]
    end

    def compile_assets(options = {})
      configure_sprockets(options)

      manifest = Sprockets::Manifest.new(
        sprockets_environment,
        assets_dir,
        File.join(assets_dir, 'manifest.json')
      )

      manifest.compile(Boiler.settings[:asset_names])
    end

    def compress_assets
      compile_assets(:compress => true)
    end

    def gzip_assets
      compress_assets

      Dir["#{assets_dir}/**/*.*"].reject { |f| f =~ /\.gz\z/ }.each do |f|
        system "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
      end
    end

    def layout_dir
      @layout_dir ||= Boiler.settings[:layout_dir]
    end

    def layout_env(layout_name)
      {
        'response.view' => layout_name
      }
    end

    def compile_layout(layout_name, options = {})
      require 'boiler/app'
      status, headers, body = Boiler::App::RenderView.new(lambda {}).call(layout_env(layout_name))

      layout_name = "#{layout_name}.html" if layout_name =~ /\A[^.]+\Z/
      layout_path = File.join(layout_dir, layout_name)

      system "rm #{layout_path}" if File.exists?(layout_path)
      File.open(layout_path, "w") do |file|
        file.write(body.first)
      end

      if options[:gzip]
        system "gzip -c #{layout_path} > #{layout_path}.gz"
      end

      puts "Layout compiled to #{layout_path}"
    end

    def compile_layouts(options = {})
      puts "Compiling layouts..."

      system  "mkdir -p #{layout_dir}"

      Boiler.settings[:layouts].each do |layout|
        compile_layout(layout[:name].to_s, options)
      end
    end

    def gzip_layouts
      compile_layouts(:gzip => true)
    end
  end
end

