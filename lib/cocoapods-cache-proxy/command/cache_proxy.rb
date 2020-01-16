require 'cocoapods-cache-proxy/gem_version'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
      
        require 'cocoapods-cache-proxy/command/cache_proxy/add'
        require 'cocoapods-cache-proxy/command/cache_proxy/update'
        require 'cocoapods-cache-proxy/command/cache_proxy/remove'
        require 'cocoapods-cache-proxy/command/cache_proxy/list'

        require 'cocoapods-cache-proxy/command/cache_proxy/auth/auth'
  
        self.abstract_command = true
        self.version = CocoapodsCacheProxy::VERSION
        self.description = '缓存代理服务'\
                            "\n v#{CocoapodsCacheProxy::VERSION}\n"
        self.summary = <<-SUMMARY
          缓存代理服务
        SUMMARY
  
        self.default_subcommand = 'list'
  
        def init
  
        end
      end
    end
  end
end
