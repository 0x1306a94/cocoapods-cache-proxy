require 'fileutils'
require 'find'
require 'json'
require 'cocoapods'
require 'yaml'
require 'uri'
require 'pathname'
require 'cocoapods-cache-proxy/native/cache_proxy_source'

module Pod
    class CacheProxySource
        class CacheProxySourceHelper

            # @return [String]
            def self.get_cache_proxy_root_dir
                "#{Pod::Config.instance.home_dir}/cache-proxy"
            end

            # @param [String] source_name
            # @return [String]
            def self.get_source_root_dir(source_name)
                "#{Pod::Config.instance.home_dir}/cache-proxy/#{source_name}"
            end

            # @@return [String]
            def self.get_source_conf_file_name
                ".cache_proxy_conf.yml"
            end

            # @param [String] source_name
            # @return [String]
            def self.get_source_conf_path(source_name)
                "#{get_source_root_dir(source_name)}/#{get_source_conf_file_name}"
            end

            # @param [String] source_name
            # @return [Void]
            def self.check_source_conf_exists(source_name)
                File.exist?(get_source_conf_path(source_name))
            end

            # @param [String] source_name
            # @return [Hash]
            def self.load_conf(source_name)
                path = get_source_conf_path(source_name)
                if File.exist?(path)
                    YAML.load_file(path)
                else
                    nil
                end
            end

            # @param [String] source_name
            # @param [String] url
            # @param [String] user
            # @param [String] password
            # @return [Void]
            def self.create_cache_proxy_source_conf(source_name, url, user, password)
                path = get_source_conf_path(source_name)
                info = {
                    name => source_name,
                    url => url,
                }

                info['user'] = user unless user.blank?
                info['password'] = password unless password.blank?
                
                conf = File.new(path, "wb")
                conf << info.to_yaml
                conf.close
                
            end
            
            
            # @param [String] cache_source_name
            # @param [String] cache_source_url
            # @param [String] user
            # @param [String] password
            # @return [Void]
            def self.init_cache_proxy_source(cache_source_name, cache_source_url, user, password)
                begin
                    show_output = Pod::Config.instance.verbose?

                    cache_source_root_path = "#{get_source_root_dir(cache_source_name)}"
                    
                    FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                    
                    FileUtils.mkdir_p(cache_source_root_path)

                    Pod::UI.message "Generating source conf .....".yellow if show_output
                    create_cache_proxy_source_conf(cache_source_name, cache_source_url, user, password)
                    Pod::UI.message "Successfully added repo #{cache_source_name}".green if show_output

                rescue Exception => e 
                    Pod::UI.message "发生异常,清理文件 .....".yellow if show_output
                    FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                    Pod::UI.message e.message.yellow if show_output
                    Pod::UI.message e.backtrace.inspect.yellow if show_output
                    raise e 
                end
            end

            # @param [String] cache_source_name
            # @return [Void]
            def self.remove_cache_proxy_source(cache_source_name)
                show_output = Pod::Config.instance.verbose?

                cache_source_root_path = "#{get_source_root_dir(cache_source_name)}"
                FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)

                Pod::UI.message "Successfully remove repo #{cache_source_name}".green if show_output
            end

            # @param [String] cache_source_name
            # @return [Pod::CacheProxySource]
            def self.get_cache_proxy_source_conf(cache_source_name)
                return nil unless (hash = load_conf(cache_source_name))
                Pod::CacheProxySource.new(hash['name'], hash['url'], hash['user'], hash['password'])
            end

            # @return [Array<Pod::CacheProxySource>]
            def self.get_all_sources
                return [] unless Dir.exist?(get_cache_proxy_root_dir)
                list = []
                Find.find(get_cache_proxy_root_dir) do |path|
                    next unless File.file?(path) && path.end_with?(".cache_proxy_conf.yml")
                    pn = Pathname.new(path)
                    source_name = pn.dirname.basename
                    next unless (conf = get_cache_proxy_source_conf(source_name))
                    list << conf
                end
                list
            end
        end
    end
end
