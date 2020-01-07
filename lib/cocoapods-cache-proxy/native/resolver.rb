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
            return specs_by_target if proxy_source.nil?

            show_output = Pod::Config.instance.verbose?
            specs_by_target.each do |target, rspecs|
                rspecs.each do |spec|
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
            specs_by_target
        end
    end
end
