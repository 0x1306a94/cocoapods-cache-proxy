require 'cocoapods'
require 'cocoapods-cache-proxy/native/config'
require 'cocoapods-cache-proxy/native/podfile_dsl'
require 'cocoapods-cache-proxy/gem_version'

module Pod
    class Resolver

        alias_method :orig_resolver_specs_by_target, :resolver_specs_by_target
        def resolver_specs_by_target
            specs_by_target = orig_resolver_specs_by_target

            return specs_by_target unless Pod::Config.instance.cache_proxy_source_available
            root_proxy_source = Pod::Config.instance.cache_proxy_source

            specs_by_target.each do |target, specs|
                specs.each do |spec|
                    root_spec = spec.spec.root
                    source = root_spec.source
                    next unless !source.blank? && source.has_key?(:git) && source.has_key?(:tag)
                    next if target.check_ignore_cache_proxy_pod(root_spec.name)

                    git = source[:git]
                    tag = source[:tag]
                    submodules = source.has_key?(:submodules) ? source[:submodules] : false

                    proxy_source = target.proxy_source_for_pod(root_spec.name)
                    new_url = (proxy_source.nil? ? root_proxy_source : proxy_source).build_proxy_source(root_spec.name, git, tag, submodules)
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
