require 'cocoapods-cache-proxy/helper/helper'

module Pod
    class Command
        class Cache < Command
            class Proxy
                class Remove < Proxy
                    self.summary = '移除缓存代理'
    
                    self.description = <<-DESC
                    移除缓存代理
                    DESC
    
                    self.arguments = [
                        CLAide::Argument.new('NAME', true),
                    ]
    
                    def initialize(argv)
                        init
                        @name = argv.shift_argument
                        @silent = argv.flag?('silent', false)
                        super
                    end
    
                    def validate!
                        super
                        unless @name
                            help! 'This command requires both a repo name.'
                        end
                    end
    
                    def run
                        raise Pod::Informative.exception "`#{@name}` 不存在" unless CPSH.check_source_conf_exists(@name)
    
                        UI.section("remove cache proxy repo `#{@name}`") do
                            CPSH.remove_cache_proxy_source(@name)
                        end
                    end
                end
            end
        end
    end
end
