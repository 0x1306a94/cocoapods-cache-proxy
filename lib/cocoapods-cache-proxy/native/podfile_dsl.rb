require 'cocoapods-core'

module Pod
    class Podfile
        module DSL

            def ignore_cache_proxy_pods!(pods = [])
                current_target_definition.set_ignore_cache_proxy_pods(pods) if !pods.blank? && !current_target_definition.nil?
            end
        end
    end
end


module Pod
    class Podfile

        class IgnorePodProxy
            def self.keyword
                :ignore_cache_proxy
            end
        end

        class UsedPodProxySource
            def self.keyword
                :cache_proxy_source
            end
        end

        class TargetDefinition
            attr_reader :ignore_cache_proxy
            attr_reader :cache_proxy_source

            #alias_method :orig_store_pod, :store_pod
            #def store_pod(name, *requirements)
            #    Pod::UI.message "store_pod requirements: #{requirements}" if Pod::Config.instance.verbose?
            #    #parse_ignore_cache_proxy(name, requirements)
            #    options = requirements.last
            #    if options.is_a?(Hash) and options.has_key?(:ignore_cache_proxy)
            #        Pod::UI.message "ignore_cache_proxy name: #{name}"
            #        options.delete(:ignore_cache_proxy)
            #        requirements.pop if options.empty?
            #    end
            #    Pod::UI.message "store_pod 2 requirements: #{requirements}" if Pod::Config.instance.verbose?
            #    orig_store_pod(name, *requirements)
            #end

            # ---- patch method ----
            # We want modify `store_pod` method, but it's hard to insert a line in the
            # implementation. So we patch a method called in `store_pod`.
            alias_method :orig_parse_inhibit_warnings, :parse_inhibit_warnings
            def parse_inhibit_warnings(name, requirements)
                options = requirements.last

                if options.is_a?(Hash)
                    if options.has_key?(Pod::Podfile::IgnorePodProxy.keyword)
                        ignore = options[Pod::Podfile::IgnorePodProxy.keyword]
                        options.delete(Pod::Podfile::IgnorePodProxy.keyword)
                        set_ignore_cache_proxy_pods([name]) if ignore
                    end

                    if options.has_key?(Pod::Podfile::UsedPodProxySource.keyword)
                        source_name = options[Pod::Podfile::UsedPodProxySource.keyword]
                        options.delete(Pod::Podfile::UsedPodProxySource.keyword)
                        unless source_name.blank?
                            raise Pod::Informative.exception "cache proxy source: `#{source_name}` source does not exist." unless (source = CPSH.get_cache_proxy_source_conf(source_name))
                            @cache_proxy_source = Hash.new if @cache_proxy_source.nil?
                            @cache_proxy_source[name] = source
                        end
                    end
                    requirements.pop if options.empty?
                end
                orig_parse_inhibit_warnings(name, requirements)
            end

            # 参考 https://github.com/leavez/cocoapods-binary/blob/9f40c5df4149598b03b44c01d33b04e78ff38772/lib/cocoapods-binary/helper/podfile_options.rb#L52-L60
            # ---- patch method ----
            # We want modify `store_pod` method, but it's hard to insert a line in the
            # implementation. So we patch a method called in `store_pod`.
            #old_method = instance_method(:parse_inhibit_warnings)
            #
            #define_method(:parse_inhibit_warnings) do |name, requirements|
            #    Pod::UI.message "parse_inhibit_warnings requirements: #{requirements}" if Pod::Config.instance.verbose?
            #    options = requirements.last
            #    if options.is_a?(Hash) and options.has_key?(:ignore_cache_proxy)
            #        Pod::UI.message "ignore_cache_proxy name: #{name}"
            #        options.delete(:ignore_cache_proxy)
            #        requirements.pop if options.empty?
            #        set_ignore_cache_proxy_pods([name])
            #    end
            #    Pod::UI.message "parse_inhibit_warnings requirements: #{requirements}" if Pod::Config.instance.verbose?
            #    old_method.bind(self).(name, requirements)
            #end

            #def parse_ignore_cache_proxy(name, requirements)
            #    requirements.each do |options|
            #        next unless options.is_a?(Hash)
            #        Pod::UI.message "parse_ignore_cache_proxy: #{options}" if Pod::Config.instance.verbose?
            #        set_ignore_cache_proxy_pods([name]) if options.has_key?(:git)
            #    end
            #end

            # @param [Array<String>] pods
            def set_ignore_cache_proxy_pods(pods)
                return if pods.blank?
                @ignore_cache_proxy = [] if @ignore_cache_proxy.nil?
                pods.uniq.each do |pod|
                    @ignore_cache_proxy << pod unless @ignore_cache_proxy.include?(pod)
                end
            end

            # @return [Array<String>]
            def get_ignore_cache_proxy_pods
                @ignore_cache_proxy.nil? ? [] : @ignore_cache_proxy.uniq
            end

            # @param [String] pod
            # @return [TrueClass, FalseClass]
            def check_ignore_cache_proxy_pod(pod)
                return false if pod.blank?
                ignores = []
                ignores.concat(get_ignore_cache_proxy_pods)
                ignores.concat(root.get_ignore_cache_proxy_pods) unless root.nil?
                ignores.concat(parent.get_ignore_cache_proxy_pods) unless parent.nil?
                ignores.uniq.include?(pod)
            end

            # @param [String] pod
            # @return [CacheProxySource]
            def proxy_source_for_pod(pod)
                return nil if @cache_proxy_source.blank?
                @cache_proxy_source[pod]
            end
        end
    end
end