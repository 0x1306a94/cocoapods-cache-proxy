require 'cocoapods-cache-proxy/helper/helper'
require 'cache_source'

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
                    sources = config.sources_manager.all
                    print_sources(sources)
                end

                def print_source(source)
                    if source.is_a?(Pod::CacheSource) && source.cache_proxy_source?
                        UI.puts "- URL:  #{source.url}"
                        UI.puts "- Path: #{source.repo}"
                    end
                end

                def print_sources(sources)
                    sources.each do |source|
                        if source.is_a?(Pod::CacheSource) && source.cache_proxy_source?
                            UI.title source.name do
                                UI.puts "- URL:  #{source.url}"
                                UI.puts "- Path: #{source.repo}"
                            end
                        end
                    end
                    UI.puts "\n"
                end
            end
        end
    end
end
