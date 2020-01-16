require 'cocoapods-cache-proxy/gem_version'
require 'cocoapods-cache-proxy/command/cache_proxy'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
        class Auth < Proxy

          require 'cocoapods-cache-proxy/command/cache_proxy/auth/add'
          require 'cocoapods-cache-proxy/command/cache_proxy/auth/update'
          require 'cocoapods-cache-proxy/command/cache_proxy/auth/remove'
          require 'cocoapods-cache-proxy/command/cache_proxy/auth/list'

          self.abstract_command = true
          self.version = CocoapodsCacheProxy::VERSION
          self.description = '缓存代理授权配置'\
                            "\n v#{CocoapodsCacheProxy::VERSION}\n"
          self.summary = <<-SUMMARY
          缓存代理授权配置
          SUMMARY

          self.default_subcommand = 'list'

          def init

          end
        end
      end
    end
  end
end