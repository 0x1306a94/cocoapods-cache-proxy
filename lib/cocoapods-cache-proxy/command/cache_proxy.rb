require 'cocoapods-cache-proxy/gem_version'

module Pod
  class Command
    class CacheProxy < Command
      
      require 'cocoapods-cache-proxy/command/cache_proxy/add'
      require 'cocoapods-cache-proxy/command/cache_proxy/remove'
      require 'cocoapods-cache-proxy/command/cache_proxy/update'
      require 'cocoapods-cache-proxy/command/cache_proxy/list'

      self.abstract_command = true
      self.version = CocoapodsCacheProxy::VERSION
      self.description = '代理缓存服务'\
                          "\n v#{CocoapodsCacheProxy::VERSION}\n"
      self.summary = <<-SUMMARY
        代理缓存
      SUMMARY

      self.default_subcommand = 'list'

      def init

      end
    end
  end
end
