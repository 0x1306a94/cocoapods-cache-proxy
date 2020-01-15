require 'cocoapods'
require 'cocoapods-cache-proxy/native/config'
require 'cocoapods-cache-proxy/native/podfile_dsl'
require 'cocoapods-cache-proxy/gem_version'

module Pod
    class Resolver

        alias_method :orig_resolver_specs_by_target, :resolver_specs_by_target
        def resolver_specs_by_target
            specs_by_target = orig_resolver_specs_by_target
            proxy_source = Pod::Config.instance.cache_proxy_source
            return specs_by_target if proxy_source.nil?

            specs_by_target.each do |target, specs|
                specs.each do |spec|
                    root_spec = spec.spec.root
                    source = root_spec.source
                    next unless !source.blank? && source.has_key?(:git) && source.has_key?(:tag)
                    next if target.check_ignore_cache_proxy_pod(root_spec.name)
                        
                    git = source[:git]
                    tag = source[:tag]
                    submodules = source.has_key?(:submodules) ? source[:submodules] : false
                    new_url = proxy_source.build_proxy_source(root_spec.name, git, tag, submodules)
                    source = {
                        :http => new_url,
                        :type => "tgz",
                    }
                    root_spec.source = source
                end
            end
            specs_by_target
        end
    end
end
