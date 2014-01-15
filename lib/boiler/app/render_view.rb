require 'erb'

module Boiler
  class App
    class RenderView < Middleware

      class TemplateContext
        AssetNotFoundError = AssetServer::SprocketsHelpers::AssetNotFoundError

        attr_reader :env, :locals
        def initialize(env, renderer, locals = {}, &block)
          @env, @renderer, @locals, @block = env, renderer, locals, block
        end

        def erb(view_name, locals = {})
          context = self.class.new(@env, @renderer, locals, &@block)
          @renderer.erb(view_name, context.instance_eval { binding })
        end

        def block_given?
          !@block.nil? && @block.respond_to?(:call)
        end

        def yield
          @block.call(self)
        end

        def current_user
          return unless (env['rack.session'] || {})['current_user_id']
          env['current_user'] ||= Model::User.find(env['rack.session']['current_user_id'])
        end

        def sprockets_environment
          AssetServer.sprockets_environment
        end

        def asset_manifest_path(asset_name)
          return unless manifest = Boiler.settings[:asset_manifest]
          return unless Hash === manifest && Hash === manifest['files']
          compiled_name = manifest['files'].find { |k,v|
            v['logical_path'] == asset_name
          }.to_a[0]

          return unless compiled_name

          full_asset_path(compiled_name)
        end

        def asset_path(name)
          path = asset_manifest_path(name)
          return path if path

          asset = sprockets_environment.find_asset(name)
          raise AssetNotFoundError.new("#{name.inspect} does not exist within #{sprockets_environment.paths.inspect}!") unless asset
          full_asset_path(asset.digest_path)
        end

        def path_prefix
          Boiler.settings[:path_prefix].to_s
        end

        def asset_root
          Boiler.settings[:asset_root].to_s
        end

        def full_path(path)
          "#{path_prefix}/#{path}".gsub(%r{/+}, '/')
        end

        def full_asset_path(path)
          asset_root + "/#{path}".gsub(%r{/+}, '/')
        end
      end

      class << self
        attr_accessor :view_roots

        def view_roots
          @view_roots ||= Boiler.settings[:view_roots]
        end
      end

      def action(env)
        env['response.view'] ||= @options[:view].to_s if @options[:view]
        return env unless env['response.view']

        status = env['response.status'] || 200
        headers = { 'Content-Type' => (@options[:content_type] || 'text/html') }.merge(env['response.headers'] || Hash.new)
        body = render(env)

        unless body
          status = 404
          body = "View not found: #{env['response.view'].inspect}"
        end

        [status, headers, [body]]
      end

      def erb(view_name, binding, &block)
        exts = %w( html erb )
        view_name = view_name.to_s
        view_paths = Array(self.class.view_roots).map do |view_root|
          File.join(view_root, view_name)
        end
        view_paths = view_paths.inject(view_paths) do |paths, path|
          paths | exts.map { |ext| "#{path}.#{ext}" } | ["#{path}.#{exts.join('.')}"]
        end
        return unless view_path = view_paths.find { |path| File.exists?(path) }

        template = ERB.new(File.read(view_path))
        template.result(binding)
      end

      private

      def render(env)
        if env['response.layout']
          layout = env['response.layout']
          view = env['response.view']
          block = proc { |binding| erb(view, template_binding(env)) }
          erb(layout, template_binding(env, &block))
        else
          erb(env['response.view'], template_binding(env))
        end
      end

      def template_binding(env, &block)
        TemplateContext.new(env, self, &block).instance_eval { binding }
      end

    end
  end
end
