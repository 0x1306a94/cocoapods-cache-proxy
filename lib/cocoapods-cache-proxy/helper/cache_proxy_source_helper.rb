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

            def self.get_cache_proxy_root_dir()
                "#{Pod::Config.instance.home_dir}/cache-proxy"
            end

            def self.get_cache_proxy_source_root_dir(source_name)
                "#{Pod::Config.instance.home_dir}/cache-proxy/#{source_name}"
            end

            def self.get_cache_proxy_source_conf_file_name()
                ".cache_proxy_conf.yml"
            end

            def self.get_cache_proxy_source_conf_path(source_name)
                "#{get_cache_proxy_source_root_dir(source_name)}/#{get_cache_proxy_source_conf_file_name()}"
            end

            def self.check_cache_proxy_source_conf_exists(source_name)
                File.exist?(get_cache_proxy_source_conf_path(source_name))
            end

            def self.load_conf(source_name)
                path = get_cache_proxy_source_conf_path(source_name)
                if File.exist?(path)
                    YAML.load_file(path)
                else
                    nil
                end
            end

            def self.create_cache_proxy_source_conf(source_name, url, user, password)
                path = get_cache_proxy_source_conf_path(source_name)
                info = {
                    'name' => source_name,
                    'url' => url,
                }

                info['user'] = user unless user.blank?
                info['password'] = password unless password.blank?
                
                conf = File.new(path, "wb")
                conf << info.to_yaml
                conf.close
                
            end
            
            
            def self.init_cache_proxy_source(cache_source_name, cache_source_url, user, password)
                begin
                    show_output = Pod::Config.instance.verbose?

                    cache_source_root_path = "#{get_cache_proxy_source_root_dir(cache_source_name)}"
                    
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

            def self.remove_cache_proxy_source(cache_source_name)
                show_output = Pod::Config.instance.verbose?

                cache_source_root_path = "#{get_cache_proxy_source_root_dir(cache_source_name)}"    
                FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)

                Pod::UI.message "Successfully remove repo #{cache_source_name}".green if show_output
            end

            def self.get_cache_proxy_source_conf(cache_source_name)
                return nil unless (hash = load_conf(cache_source_name))
                Pod::CacheProxySource.new(hash['name'], hash['url'], hash['user'], hash['password'])
            end

            def self.get_all_cache_proxy_source_conf()
                return [] unless Dir.exist?(get_cache_proxy_root_dir())
                confs = []
                Find.find(get_cache_proxy_root_dir()) do |path|
                    next unless File.file?(path) && path.end_with?(".cache_proxy_conf.yml")
                    pn = Pathname.new(path)
                    source_name = pn.dirname.basename
                    next unless (conf = get_cache_proxy_source_conf(source_name))
                    confs << conf
                end
                confs
            end
        end
    end
end
