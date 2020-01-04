require 'cocoapods'
require 'cocoapods-downloader'
require 'cocoapods-cache-proxy/native/native'
require 'cache_source'
require 'cocoapods-cache-proxy/helper/helper'
require 'yaml'
require 'uri'

Pod::HooksManager.register('cocoapods-cache-proxy', :source_provider) do |context, options|
    Pod::UI.message 'cocoapods-cache-proxy received source_provider hook'
    return unless (sources = options['sources'])
    sources.each do |source_name|
        Pod::UI.message "source_name: #{source_name}"
        source = create_source_from_name(source_name)
        context.add_source(source)
        # raise Pod::Informative.exception "cache proxy source: `#{source_name}` does not exist." unless CPSH.check_proxy_source_exists(source_name)
    end
end


def create_source_from_name(source_name)
    repos_dir = Pod::Config.instance.repos_dir
    repo = repos_dir + source_name

    # Pod::UI.message "#{CPSH.get_cache_proxy_source_conf_path(source_name)}\n"

    # if File.exist?(CPSH.get_cache_proxy_source_conf_path(source_name))
    #     url = File.read(CPSH.get_cache_proxy_source_conf_path(source_name))
    #     Pod::CacheSource.new(CPSH.get_cache_proxy_source_root_dir(source_name), url)
    # elsif Dir.exist?("#{repo}")
    #     Pod::CacheSource.new(repo, '');
    # else
    #  raise Pod::Informative.exception "repo #{source_name} does not exist."
    # end

    if Dir.exist?("#{repo}")
        url = ''
        if File.exist?("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
          hash = YAML.load_file("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
          url = hash['url']
        end
        Pod::CacheSource.new(repo, url);
    else
     raise Pod::Informative.exception "repo #{source_name} does not exist."
    end
end

module Pod
  module Downloader
    class Http
      # Force flattening of index downloads with :indexDownload => true
      def self.options
        [:type, :flatten, :sha1, :sha256, :indexDownload]
      end

      alias_method :orig_download_file, :download_file
      alias_method :orig_should_flatten?, :should_flatten?

      def download_file(full_filename)
        Pod::UI.message "full_filename: #{full_filename}" if !Pod::Config.instance.silent?
        
        uri = URI(url)
        Pod::UI.message "url: #{uri.path}" if !Pod::Config.instance.silent?
        if uri.path.start_with?("/cocoapods/proxy") 
          paths = uri.path.delete_prefix("/").split("/")
          if paths.count != 5
            orig_download_file(full_filename)
            return
          end

          source_name = paths[3]
          repos_dir = Pod::Config.instance.repos_dir
          repo = repos_dir + source_name

          if Dir.exist?("#{repo}")
              user = ""
              password = ""
              if File.exist?("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
                hash = YAML.load_file("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
                user = hash['user']
                password = hash['password']
                Pod::UI.message "hash: #{hash}"
              end
              curl_options = []
              curl_options.concat(["-u", "#{user}:#{password}"]) unless user.blank? && password.blank?
              curl_options.concat(["-f", "-L", "-o", full_filename, url, "--create-dirs"])
              Pod::UI.message "curl_options: #{curl_options.join(" ")}" if !Pod::Config.instance.silent?
              curl! curl_options
          else
            raise Pod::Informative.exception "repo #{source_name} does not exist."
          end
        else
          orig_download_file(full_filename)
        end
        # curl_options = ["-f", "-L", "-o", full_filename, url, "--create-dirs", "--netrc-optional"]

        # ssl_conf = ["--cert", `git config --global http.sslcert`.gsub("\n", ""), "--key", `git config --global http.sslkey`.gsub("\n", "")]
        # curl_options.concat(ssl_conf) if !ssl_conf.any?(&:blank?)

        # netrc_path = ENV["COCOAPODS_ART_NETRC_PATH"]
        # curl_options.concat(["--netrc-file", Pathname.new(netrc_path).expand_path]) if netrc_path

        # curl! curl_options
      end

      # Note that we disabled flattening here for the ENTIRE client to deal with
      # default flattening for non zip archives messing up tarballs incoming
      def should_flatten?
        # TODO uncomment when Artifactory stops sending the :flatten flag
        # if options.key?(:flatten)
        #   true
        # else
        #   false
        # end
        if options.key?(:indexDownload)
          true
        else
          orig_should_flatten?
        end
      end
    end
  end
end


module Pod
    class Installer
        class Analyzer

          alias_method :orig_sources, :sources

          def sources
            if podfile.sources.empty? && podfile.plugins.keys.include?('cocoapods-cache-proxy')
              sources = Array.new
              plugin_config = podfile.plugins['cocoapods-cache-proxy']
              # all sources declared in the plugin clause
              plugin_config['sources'].uniq.map do |name|
                sources.push(create_source_from_name(name))
              end
              @sources = sources
            else
              orig_sources
            end
          end
        end
    end
end

module Pod
    class Source
        class Manager

          alias_method :orig_source_from_path, :source_from_path
          
          # @return [Source] The Source at a given path.
          #
          # @param [Pathname] path
          #        The local file path to one podspec repo.
          #
          def source_from_path(path)
            @sources_by_path ||= Hash.new do |hash, key|
              hash[key] = if key.basename.to_s == Pod::TrunkSource::TRUNK_REPO_NAME
                            TrunkSource.new(key)
                          elsif File.exist?(CPSH.get_cache_proxy_source_conf_path(key.basename))
                            create_source_from_name(key.basename)
                          else
                            Source.new(key)
                          end
            end
            @sources_by_path[path]
          end

        end
    end
end