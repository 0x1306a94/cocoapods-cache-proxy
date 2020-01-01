require 'cocoapods-cache-proxy/helper/helper'

module Pod
    class Command
        class CacheProxy
            class List < CacheProxy
                self.summary = '列出缓存代理'

                self.description = <<-DESC
                列出缓存代理
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

                    UI.section("list cache proxy repo ") do
                        # CPSH.remove_cache_proxy_source(@name)
                    end
                end
            end
        end
    end
end
