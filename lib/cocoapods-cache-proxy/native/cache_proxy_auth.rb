module Pod
  class CacheProxyAuth

    # @param [String] host
    # @param [String] token
    def initialize(host, token)
      @host = host
      @token = token
    end

    # @return [String]
    def host
      @host
    end

    def token
      @token
    end
  end
end