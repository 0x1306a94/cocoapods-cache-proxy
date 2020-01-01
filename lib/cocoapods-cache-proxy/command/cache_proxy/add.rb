require 'cocoapods-cache-proxy/helper/helper'

module Pod
    class Command
        class CacheProxy
            class Add < CacheProxy
                self.summary = '添加缓存代理'

                self.description = <<-DESC
                添加缓存代理
                DESC

                self.arguments = [
                    CLAide::Argument.new('NAME', false),
                    CLAide::Argument.new('URL', false)
                ]

                def initialize(argv)
                    init
                    @name, @url = argv.shift_argument, argv.shift_argument
                    @silent = argv.flag?('silent', false)
                    super
                end

                def validate!
                    super
                    unless @name && @url
                        help! 'This command requires both a repo name and a url.'
                    end
                end

                def run
                    raise Pod::Informative.exception "`#{@name}` 已经存在" if CPSH.check_cache_proxy_source_conf_exists(@name)
                    raise Pod::Informative.exception "官方源不存在, 请执行 `pod setup` 已经存在" unless Dir.exists?(CPSH.get_official_master_source_root_path())

                    UI.section("Add proxy server config `#{@url}` into local spec repo `#{@name}`") do
                        # official_source = if Dir.exists?(CPSH.get_official_cnd_source_root_path())
                        #     "trunk"
                        # else
                        #     "master"
                        # end
                        CPSH.init_cache_proxy_source("master", @name, @url)
                    end
                end
            end
        end
    end
end
