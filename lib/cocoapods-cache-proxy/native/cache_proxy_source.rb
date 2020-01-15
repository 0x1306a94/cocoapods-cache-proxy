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
            "#{@baseURL}/#{pod}?git=#{git}&tag=#{tag}&submodules=#{submodules}"
        end
    end
end