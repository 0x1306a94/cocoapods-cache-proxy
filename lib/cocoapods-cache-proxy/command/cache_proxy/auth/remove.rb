require 'cocoapods-cache-proxy/helper/helper'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
        class Auth < Proxy
          class Remove < Auth
            self.summary = '移除缓存代理授权配置'

            self.description = <<-DESC
                    移除缓存代理授权配置
            DESC

            self.arguments = [
                CLAide::Argument.new('HOST', true),
            ]

            def initialize(argv)
              init
              @host = argv.shift_argument
              @silent = argv.flag?('silent', false)
              super
            end

            def validate!
              super
              help! 'This command requires both a auth host.' unless @host
            end

            def run
              raise Pod::Informative.exception "`#{@host}` 不存在" unless CPSH.check_auth_conf_exists(@host)

              UI.section("remove cache proxy auth `#{@host}`".green) do
                CPSH.remove_cache_proxy_auth(@host)
              end
            end
          end
        end
      end
    end
  end
end
