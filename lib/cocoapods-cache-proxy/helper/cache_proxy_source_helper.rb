require 'fileutils'
require 'find'
require 'json'

module Pod
    class CacheProxySource
        class CacheProxySourceHelper

            def self.get_cache_proxy_root_dir()
                "#{Pod::Config.instance.home_dir}/cache-proxy"
            end

            def self.get_cache_proxy_source_root_dir(source_name)
                "#{Pod::Config.instance.home_dir}/cache-proxy/#{source_name}"
            end

            def self.get_cache_proxy_source_conf_path(source_name)
                "#{get_cache_proxy_source_root_dir(source_name)}/.conf"
            end

            def self.check_cache_proxy_source_conf_exists(source_name)
                File.exist?(get_cache_proxy_source_conf_path(source_name))
            end

            def self.get_cache_proxy_source_spec_root_dir(source_name)
                "#{get_cache_proxy_source_root_dir(source_name)}/#{source_name}"
            end

            def self.create_cache_proxy_source_conf(source_name, url)
                path = get_cache_proxy_source_conf_path(source_name)
                conf = File.new(path, "wb")
                conf << url
                conf.close
                path
            end
            
            def self.init_cache_proxy_source(official_source_name, cache_source_name, cache_sour_url)
                repos_root_path = "#{Pod::Config.instance.home_dir}/repos"
                official_source_root_path = "#{repos_root_path}/#{official_source_name}"
                official_specs_root_path = "#{official_source_root_path}/Specs"

                cache_source_root_path = "#{get_cache_proxy_source_spec_root_dir(cache_source_name)}"
                cache_specs_root_path = "#{cache_source_root_path}/Specs"
                
                FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                
                FileUtils.mkdir_p(cache_source_root_path)

                Pod::UI.message "official_source_root_path: #{official_source_root_path}" unless @silent
                Pod::UI.message "cache_source_root_path: #{cache_source_root_path}" unless @silent
                Pod::UI.message "Generating source from `#{official_source_name}` .....".yellow unless @silent

                Find.find(official_specs_root_path) do |path|
                    next unless File.file?(path) && path.end_with?(".podspec.json")

                    json = File.read(path)
                    obj = JSON.parse(json)
                    name = obj['name']
                    version = obj['version']
                    o_source = obj['source']
                    # 只修改 git 的方式
                    if !o_source.blank? && o_source.has_key?("git") && o_source.has_key?("tag")
                        params = []
                        o_source.each do |key, value| 
                            params.push("#{key}=#{value}")
                        end
                        file_name = "#{name}-#{version}.zip"
                        n_source = { "http" => "http://127.0.0.1:9090/file/#{cache_source_name}/#{file_name}?#{params.join("&")}" }
                        obj['source'] = n_source
                        Pod::UI.message "source: #{o_source}" unless @silent
                        Pod::UI.message "new source: #{n_source}" unless @silent
                        # newPath = path.gsub(official_source_root_path, cache_source_root_path
                    end

                    newPath = "#{cache_specs_root_path}/#{name}/#{version}/#{File.basename(path)}"

                    FileUtils.mkdir_p(File.dirname(newPath)) unless File.directory?(File.dirname(newPath))
                    spec_file = File.new(newPath, "wb")
                    spec_file << JSON.pretty_generate(obj)
                    spec_file.close
                end

                Pod::UI.message "Generating source conf .....".yellow unless @silent
                create_cache_proxy_source_conf(cache_source_name, cache_sour_url)

                Pod::UI.message "#{cache_source_root_path}: init git .....".yellow unless @silent
                system "cd '#{cache_source_root_path}' && git init && git add . && git commit -m 'cache repo init'"

                Pod::UI.message "git clone file://#{cache_source_root_path} .....".yellow unless @silent
                system "cd '#{repos_root_path}' && git clone file://#{cache_source_root_path} --verbose"

                Pod::UI.message "Successfully added repo #{cache_source_name}".green unless @silent
            end

            def self.remove_cache_proxy_source(cache_source_name)
                repos_root_path = "#{Pod::Config.instance.home_dir}/repos"
                cache_source_root_path = "#{repos_root_path}/#{cache_source_name}"
                FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                FileUtils.rm_rf(get_cache_proxy_source_root_dir(cache_source_name)) if Dir.exist?(get_cache_proxy_source_root_dir(cache_source_name))
                Pod::UI.message "Successfully remove repo #{cache_source_name}".green unless @silent
            end

            def self.get_official_master_source_root_path()
                "#{Pod::Config.instance.home_dir}/repos/master"
            end

            def self.get_official_cnd_source_root_path()
                "#{Pod::Config.instance.home_dir}/repos/trunk"
            end
        end
    end
end
