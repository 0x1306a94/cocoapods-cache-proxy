require 'cocoapods-core/source'
require 'cocoapods-cache-proxy/helper/helper'

module Pod
  
  class CacheSource < Source

    alias_method :old_url, :url

    # @param [String] repo The name of the repository
    #
    # @param [String] url see {#url}
    #
    def initialize(repo, url)
      super(repo)
      @source_url = url
    end

    # def type
    #   "#{repo.basename}"
    # end

    # @return url of this repo
    def url
      if @source_url
        "#{@source_url}"
      else
        # after super(repo) repo is now the path to the repo
        File.read(CPSH.get_cache_proxy_source_conf_path(repo)) if CPSH.check_cache_proxy_source_conf_exists(repo)
      end
    end

    def git?
      true
    end
  end
end
