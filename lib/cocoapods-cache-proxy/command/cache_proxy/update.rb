require 'cocoapods-cache-proxy/helper/helper'

module Pod
    class Command
        class Cache < Command
            class Proxy < Cache
                class Update < Proxy
                    self.summary = '更新缓存代理'
    
                    self.description = <<-DESC
                    更新缓存代理
                    DESC
    
                    self.arguments = [
                        CLAide::Argument.new('NAME', true),
                        CLAide::Argument.new('URL', true),
                        CLAide::Argument.new('USER', true),
                        CLAide::Argument.new('PASSWORD', true)
                    ]
    
                    def initialize(argv)
                        init
                        @name, @url, @user, @password = argv.shift_argument, argv.shift_argument, argv.shift_argument, argv.shift_argument
                        @silent = argv.flag?('silent', false)
                        super
                    end
    
                    def validate!
                        super
                        help! 'This command requires both a repo name.' unless @name
                        help! 'This command requires both a repo url.' unless @url
                        help! 'This command requires both a repo user.' unless @user
                        help! 'This command requires both a repo password.' unless @password
                    end
    
                    def run
                        raise Pod::Informative.exception "`#{@name}` 不存在" unless CPSH.check_source_conf_exists(@name)
    
                        UI.section("Update cache proxy repo `#{@name}`".green) do
                            CPSH.init_cache_proxy_source(@name, @url, @user, @password)
                        end
                    end
                end
            end
        end
    end
end
