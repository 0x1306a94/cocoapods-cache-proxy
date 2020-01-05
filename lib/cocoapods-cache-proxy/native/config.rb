require 'cocoapods-cache-proxy/native/cache_proxy_source'
require 'cocoapods-cache-proxy/helper/helper'

module Pod
    class Config
        attr_reader :cache_proxy_source

        def set_cache_proxy_source(name)
            return if name.blank?
            return unless (cnf = CPSH.get_cache_proxy_source_conf(name))
            @cache_proxy_source = cnf
        end

        def cache_proxy_source()
            @cache_proxy_source
        end

        # def remove_cache_proxy_source(name)
        #     return if name.blank? || @cache_proxy_source.nil? || @cache_proxy_source.empty?
        #     @cache_proxy_source.delete_if { |cnf| cnf.name == name }
        # end

        # def get_all_cache_proxy_sources()
        #     return [] if @cache_proxy_source.nil?
        #     @cache_proxy_source
        # end
    end
end