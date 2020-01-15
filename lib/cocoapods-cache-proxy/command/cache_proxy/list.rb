require 'cocoapods-cache-proxy/helper/helper'
require 'cocoapods-cache-proxy/native/cache_proxy_source'

module Pod
    class Command
        class Cache < Command
            class Proxy
                class List < Proxy
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
                        sources = CPSH.get_all_sources
                        print_sources(sources)
                    end
    
                    def print_source(source)
                        if source.is_a?(Pod::CacheProxySource)
                            UI.puts "- URL:  #{source.baseURL}"
                            UI.puts "- Path: #{CPSH.get_source_root_dir(source.name)}"
                        end
                    end
    
                    def print_sources(sources)
                        sources.each do |source|
                            if source.is_a?(Pod::CacheProxySource)
                                UI.title source.name do
                                    UI.puts "- URL:  #{source.baseURL}"
                                    UI.puts "- Path: #{CPSH.get_source_root_dir(source.name)}"
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
