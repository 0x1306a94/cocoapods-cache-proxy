require 'fileutils'
require 'find'
require 'json'
require 'cocoapods'
require 'yaml'
require 'uri'

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
            
            def self.init_cache_proxy_source(official_source_name, cache_source_name, cache_source_url, user, password)
                begin
                    show_output = !Pod::Config.instance.silent?

                    repos_root_path = "#{Pod::Config.instance.home_dir}/repos"
                    official_source_root_path = "#{repos_root_path}/#{official_source_name}"
                    official_specs_root_path = "#{official_source_root_path}/Specs"

                    cache_source_root_path = "#{get_cache_proxy_source_root_dir(cache_source_name)}"
                    cache_specs_root_path = "#{cache_source_root_path}/Specs"
                    
                    FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                    
                    FileUtils.mkdir_p(cache_source_root_path)

                    Pod::UI.message "official_source_root_path: #{official_source_root_path}" if show_output
                    Pod::UI.message "cache_source_root_path: #{cache_source_root_path}" if show_output
                    Pod::UI.message "Generating source from `#{official_source_name}` .....".yellow if show_output
                    # count = 0
                    Find.find(official_specs_root_path) do |path|
                        # break if count >= 1000
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
                            new_url = "#{cache_source_url}/#{name}?#{URI::encode(params.join("&"))}"
                            n_source = { 
                                "http" => new_url,
                                "type" => "zip",
                            }
                            obj['source'] = n_source
                            Pod::UI.message "source: #{o_source}" if show_output
                            Pod::UI.message "new source: #{n_source}" if show_output
                        end

                        newPath = "#{cache_specs_root_path}/#{name}/#{version}/#{File.basename(path)}"

                        # count += 1

                        FileUtils.mkdir_p(File.dirname(newPath)) unless File.directory?(File.dirname(newPath))
                        spec_file = File.new(newPath, "wb")
                        spec_file << JSON.pretty_generate(obj)
                        spec_file.close
                       
                    end

                    Pod::UI.message "Generating source conf .....".yellow if show_output
                    create_cache_proxy_source_conf(cache_source_name, cache_source_url, user, password)

                    Pod::UI.message "#{cache_source_root_path}: init git .....".yellow if show_output
                    system "cd '#{cache_source_root_path}' && git init && git add . && git commit -m 'cache repo init'"

                    # Pod::UI.message "git clone file://#{cache_source_root_path} .....".yellow if show_output
                    # system "cd '#{repos_root_path}' && git clone file://#{cache_source_root_path} --verbose"

                    argvs = [
                        cache_source_name,
                        "file://#{cache_source_root_path}"
                    ]

                    argvs << "--verbose" if show_output
                    # Pod::UI.message argvs.join(" ") if show_output
                    cmd = Pod::Command::Lib::Repo::Add.new(CLAide::ARGV.new(argvs))
                    cmd.validate!
                    cmd.run
                    
                    Pod::UI.message "Successfully added repo #{cache_source_name}".green if show_output
                rescue Exception => e 
                    Pod::UI.message "发生异常,清理文件 .....".yellow if show_output
                    FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                    Pod::UI.message e.message.yellow if show_output
                    Pod::UI.message e.backtrace.inspect.yellow if show_output
                    raise e 
                end
            end

            def self.update_cache_proxy_source(cache_source_name)
                begin
                    sources_manager = Pod::Config.instance.sources_manager
                    show_output = !Pod::Config.instance.silent?
                    sources_manager.update("master", show_output)

                    repos_root_path = "#{Pod::Config.instance.home_dir}/repos"
                    official_source_root_path = "#{repos_root_path}/master"
                    official_specs_root_path = "#{official_source_root_path}/Specs"

                    cache_source_root_path = "#{get_cache_proxy_source_root_dir(cache_source_name)}"
                    cache_specs_root_path = "#{cache_source_root_path}/Specs"

                    url = load_conf(cache_source_name)['url']

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
                            new_url = "#{url}/#{name}?#{URI::encode(params.join("&"))}"
                            n_source = { 
                                "http" => new_url,
                                "type" => "zip",
                            }
                            obj['source'] = n_source
                            Pod::UI.message "source: #{o_source}" if show_output
                            Pod::UI.message "new source: #{n_source}" if show_output
                        end
                        
                        newPath = "#{cache_specs_root_path}/#{name}/#{version}/#{File.basename(path)}"

                        FileUtils.mkdir_p(File.dirname(newPath)) unless File.directory?(File.dirname(newPath))
                        spec_file = File.new(newPath, "wb")
                        spec_file << JSON.pretty_generate(obj)
                        spec_file.close
                    end

                    system "cd '#{cache_source_root_path}' git add . && git commit -m 'cache update repo'"

                    sources_manager.update(cache_source_name, show_output)

                    # Pod::UI.message "git pull file://#{cache_source_root_path} .....".yellow unless @silent
                    # system "cd '#{repos_root_path}/#{cache_source_name}' && git pull --verbose"

                    Pod::UI.message "Successfully update repo #{cache_source_name}".green if show_output
                rescue Exception => e 
                    Pod::UI.message e.message.yellow if show_output
                    Pod::UI.message e.backtrace.inspect.yellow if show_output
                    raise e 
                end
            end

            def self.remove_cache_proxy_source(cache_source_name)
                show_output = !Pod::Config.instance.silent?

                repos_root_path = "#{Pod::Config.instance.home_dir}/repos"
                cache_source_root_path = "#{repos_root_path}/#{cache_source_name}"
                FileUtils.rm_rf(cache_source_root_path) if Dir.exist?(cache_source_root_path)
                FileUtils.rm_rf(get_cache_proxy_source_root_dir(cache_source_name)) if Dir.exist?(get_cache_proxy_source_root_dir(cache_source_name))
                Pod::UI.message "Successfully remove repo #{cache_source_name}".green if show_output
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
