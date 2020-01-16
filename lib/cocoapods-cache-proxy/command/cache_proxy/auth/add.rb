require 'cocoapods-cache-proxy/helper/helper'

module Pod
  class Command
    class Cache < Command
      class Proxy < Cache
        class Auth < Proxy
          class Add < Auth
            self.summary = '添加缓存代理授权配置'

            self.description = <<-DESC
                    添加缓存代理授权配置
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
              raise Pod::Informative.exception "`#{@host}` 已经存在" if CPSH.check_auth_conf_exists(@host)

              UI.section("Add proxy auth config `#{@host}`".green) do
                CPSH.init_cache_proxy_auth(@host, @token)
              end
            end
          end
        end
      end
    end
  end
end
