require 'cocoapods-cache-proxy/helper/helper'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
        class Auth < Proxy
          class Update < Auth
            self.summary = '更新缓存代理授权配置'

            self.description = <<-DESC
                    更新缓存代理授权配置
            DESC

            self.arguments = [
                CLAide::Argument.new('HOST', true),
                CLAide::Argument.new('TOKEN', true),
            ]

            def initialize(argv)
              init
              @host, @token = argv.shift_argument, argv.shift_argument
              @silent = argv.flag?('silent', false)
              super
            end

            def validate!
              super
              help! 'This command requires both a auth host.' unless @host
              help! 'This command requires both a auth token.' unless @token
            end

            def run
              raise Pod::Informative.exception "`#{@host}` 不存在" unless CPSH.check_auth_conf_exists(@host)

              UI.section("Update proxy auth config `#{@host}`".green) do
                CPSH.init_cache_proxy_auth(@host, @token)
              end
            end
          end
        end
      end
    end
  end
end
