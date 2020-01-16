require 'cocoapods-cache-proxy/helper/helper'
require 'cocoapods-cache-proxy/native/cache_proxy_auth'
require 'uri'

module Pod
    class CacheProxySource


        # @param [String] name
        # @param [String] baseURL
        # @param [String] user
        # @param [String] password
        def initialize(name, baseURL, user, password)
            @name = name
            @baseURL = baseURL
            @user = user
            @password = password
        end


        # @return [String]
        def name
            @name
        end

        def baseURL
            @baseURL
        end

        def user
            @user
        end

        def password
            @password
        end

        # @param [String] pod pod name
        # @param [String] git repo address
        # @param [String] tag repo tag
        # @param [String] submodules need update submodules
        # @return [String] full download url
        def build_proxy_source(pod, git, tag, submodules = false)
            auth_cnf = CPSH.get_cache_proxy_auth_conf_host(git)
            if auth_cnf.nil?
                uri = URI.parse("#{@baseURL}/#{pod}?git=#{git}&tag=#{tag}&submodules=#{submodules}&cache_proxy=1")
                uri.user = @user
                uri.password = @password
                uri.to_s
            else
                uri = URI.parse(git)
                uri.user = "oauth2"
                uri.password = auth_cnf.token
                url = uri.to_s
                uri = URI.parse("#{@baseURL}/#{pod}?git=#{url}&tag=#{tag}&submodules=#{submodules}&cache_proxy=1")
                uri.user = @user
                uri.password = @password
                uri.to_s
            end
        end
    end
end