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
                    CLAide::Argument.new('NAME', true),
                    CLAide::Argument.new('URL', true),
                    CLAide::Argument.new('USER', false),
                    CLAide::Argument.new('PASSWORD', false)
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
                    raise Pod::Informative.exception "`#{@name}` 已经存在" if CPSH.check_cache_proxy_source_conf_exists(@name)
                    raise Pod::Informative.exception "官方源不存在, 请执行 `pod setup` 已经存在" unless Dir.exists?(CPSH.get_official_master_source_root_path())

                    UI.section("Add proxy server config `#{@url}` into local spec repo `#{@name}`") do
                        CPSH.init_cache_proxy_source("master", @name, @url, @user, @password)
                    end
                end
            end
        end
    end
end
