require 'cocoapods'
require 'cocoapods-cache-proxy/native/config'
require 'cocoapods-cache-proxy/native/podfile_dsl'
require 'cocoapods-cache-proxy/gem_version'

module Pod
    class Resolver

        alias_method :orig_resolver_specs_by_target, :resolver_specs_by_target
        def resolver_specs_by_target()
            specs_by_target = orig_resolver_specs_by_target()
            proxy_source = Pod::Config.instance.cache_proxy_source
            return if proxy_source.nil?

            show_output = Pod::Config.instance.verbose?
            specs_by_target.each do |target, rspecs|
                rspecs.each do |spec|
                    # spec.spec.source = { :http => 'http://127.0.0.1:9898/static/AFNetworking.zip'}
                    root_spec = spec.spec.root
                    source = root_spec.source
                    UI.message "spec name: #{root_spec.name}" if show_output
                    UI.message "spec source: #{source}" if show_output
                    UI.message "spec version: #{root_spec.version}" if show_output
                    next unless !source.blank? && source.has_key?(:git) && source.has_key?(:tag)
                    UI.message "ignore_cache_proxy_pod: #{target.name} #{root_spec.name}" if show_output; next if target.check_ignore_cache_proxy_pod(root_spec.name)
                        
                    git = source[:git]
                    tag = source[:tag]
                    submodules = source.has_key?(:submodules) ? source[:submodules] : false
                    new_url = proxy_source.build_proxy_source(root_spec.name, git, tag, submodules)
                    source = {
                        :http => new_url,
                        :type => "tgz",
                    }
                    UI.message "spec new source: #{source}" if show_output
                    root_spec.source = source
                    
                end
            end
            # exit 0
        end

        
        # old_resolver_specs_by_target = instance_method(:resolver_specs_by_target)
        # define_method(:resolver_specs_by_target) do
        #     specs_by_target = old_resolver_specs_by_target.bind(self).call()
        #     # UI.message "specs_by_target: #{specs_by_target}"
        #     UI.message "specs_by_target:"
        #     specs_by_target.each do |target, rspecs|
        #         # if !rspecs.empty?
        #         #     UI.message "rspecs: #{rspecs}\n"
        #         #     res = rspecs.first
        #         #     UI.message "res: #{res}\n"
        #         #     root_spec = res.spec.root
        #         #     UI.message "specs_by_target root_spec name: #{root_spec.name}"
        #         #     UI.message "specs_by_target root_spec version: #{root_spec.version}"
        #         #     UI.message "specs_by_target origin source: #{root_spec.source}"
        #         # end
        #         # UI.message "spec target: #{target.class}"
        #         # dependencies = target.get_hash_value('dependencies', [])
        #         # UI.message "dependencies: #{dependencies}"
        #         # exit 0
        #         rspecs.each do |spec|
        #             # spec.spec.source = { :http => 'http://127.0.0.1:9898/static/AFNetworking.zip'}
        #             root_spec = spec.spec.root
        #             UI.message "spec source: #{root_spec.source}"
        #             UI.message "spec name: #{root_spec.name}"
        #             UI.message "spec version: #{root_spec.version}"
        #             if target.check_ignore_cache_proxy_pod(root_spec.name) 
        #                 UI.message "check_ignore_cache_proxy_pod: #{root_spec.name}"
        #             end
        #         end
        #         # TODO
        #         # 查找缓存代理, 如果命中 则修改地址为 缓存代理地址 
        #         # specs_by_target[target] =  rspecs.map do |spec|
        #         #     spec.spec.source = { :http => 'http://127.0.0.1:9898/static/AFNetworking.zip'}
        #         #     spec
        #         # end
        #     end
        #     exit 0
        # end
    end
end
