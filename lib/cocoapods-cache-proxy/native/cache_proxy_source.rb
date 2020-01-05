module Pod
    class CacheProxySource
        # @param [String] proxy_source The name of the repository
        #
        # @param [String] url see {#url}
        #
        def initialize(name, baseURL, user, password)
            @name = name
            @baseURL = baseURL
            @user = user
            @password = password
        end

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

        def build_proxy_source(pod, git, tag, submodules = false)
            "#{@baseURL}/#{pod}?git=#{git}&tag=#{tag}&submodules=#{submodules}"
        end
    end
end