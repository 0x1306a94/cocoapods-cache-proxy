require 'cocoapods-cache-proxy/helper/helper'
require 'cocoapods-cache-proxy/native/cache_proxy_auth'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
        class Auth < Proxy
          class List < Auth
            self.summary = '列出缓存代理授权配置'

            self.description = <<-DESC
                    列出缓存代理授权配置
            DESC

            def initialize(argv)
              init
              @silent = argv.flag?('silent', false)
              super
            end

            def validate!
              super
            end

            def run
              auths = CPSH.get_all_auths
              print_auths(auths)
            end

            def print_auth(auth)
              if auth.is_a?(Pod::CacheProxyAuth)
                UI.puts "- Host:  #{auth.host}"
                UI.puts "- Token: #{auth.token}"
              end
            end

            def print_auths(auths)
              auths.each_with_index do |auth, index|
                if auth.is_a?(Pod::CacheProxyAuth)
                  UI.title "auth config: #{index + 1}" do
                    UI.puts "- Host:  #{auth.host}"
                    UI.puts "- Token: #{auth.token}"
                  end
                end
              end
              UI.puts "\n"
            end
          end
        end
      end
    end
  end
end
