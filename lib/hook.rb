require 'cocoapods'
require 'cocoapods-downloader'
require 'cocoapods-cache-proxy/native/native'
require 'cocoapods-cache-proxy/helper/helper'
require 'yaml'
require 'uri'


Pod::HooksManager.register('cocoapods-cache-proxy', :source_provider) do |context, options|
    show_output = Pod::Config.instance.verbose?
    Pod::UI.message 'cocoapods-cache-proxy received source_provider hook' if show_output

    return unless (proxy_name = options['proxy'])
    raise Pod::Informative.exception "cache proxy source: `#{proxy_name}` source does not exist." unless CPSH.check_source_conf_exists(proxy_name)
    Pod::UI.message "proxy_name: #{proxy_name}" if show_output
    Pod::Config.instance.set_cache_proxy_source(proxy_name)
end
