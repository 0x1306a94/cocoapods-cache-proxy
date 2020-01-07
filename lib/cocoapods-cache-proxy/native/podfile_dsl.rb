require 'cocoapods-core'

module Pod
    class Podfile
        module DSL
            
            def ignore_cache_proxy_pods!(pods = [])
                Pod::UI.puts "current_target_definition: #{current_target_definition}" if Pod::Config.instance.verbose?
                current_target_definition.set_ignore_cache_proxy_pods(pods) if !pods.blank? && !current_target_definition.nil?
            end
        end
    end
end


module Pod
    class Podfile
        class TargetDefinition
            attr_reader :ignore_cache_proxy

            alias_method :orig_store_pod, :store_pod
            def store_pod(name, *requirements)
                Pod::UI.message "store_pod requirements: #{requirements}" if Pod::Config.instance.verbose?
                parse_ignore_cache_proxy(name, requirements)
                orig_store_pod(name, *requirements)
            end

            def parse_ignore_cache_proxy(name, requirements)
                requirements.each do |options|
                    next unless options.is_a?(Hash)
                    Pod::UI.message "parse_ignore_cache_proxy: #{options}" if Pod::Config.instance.verbose?
                    set_ignore_cache_proxy_pods([name]) if options.has_key?(:git)
                end
            end

            def set_ignore_cache_proxy_pods(pods)
                return if pods.blank?
                @ignore_cache_proxy = [] if @ignore_cache_proxy.nil?
                pods.uniq.each do |pod|
                    @ignore_cache_proxy << pod unless @ignore_cache_proxy.include?(pod)
                end
                Pod::UI.message "set_ignore_cache_proxy_pods name: #{@ignore_cache_proxy}" if Pod::Config.instance.verbose?
            end

            def get_ignore_cache_proxy_pods()
                if @ignore_cache_proxy.nil?
                    []
                else
                    @ignore_cache_proxy.uniq
                end
            end

            def check_ignore_cache_proxy_pod(pod)
                return false if pod.blank?
                ignores = []
                ignores.concat(get_ignore_cache_proxy_pods())
                ignores.concat(root.get_ignore_cache_proxy_pods()) if !root?
                ignores.concat(parent.get_ignore_cache_proxy_pods()) unless parent.nil?
                Pod::UI.message "check_ignore_cache_proxy_pod #{name}: #{ignores} #{ignores.uniq.include?(pod)}" if Pod::Config.instance.verbose?
                return ignores.uniq.include?(pod)
            end
        end
    end
end