require 'cocoapods'
require 'cocoapods-downloader'
require 'cocoapods-cache-proxy/native/native'
require 'cache_source'
require 'cocoapods-cache-proxy/helper/helper'
require 'yaml'
require 'uri'

# Pod::HooksManager.register('cocoapods-cache-proxy', :source_provider) do |context, options|
#     Pod::UI.message 'cocoapods-cache-proxy received source_provider hook'
#     Pod::UI.message "master_repo_dir: #{Pod::Config.instance.sources_manager.master_repo_dir}"
    
#     # return unless (sources = options['sources'])
#     # sources.each do |source_name|
#         # Pod::UI.message "source_name: #{source_name}"
#         # source = create_source_from_name(source_name)
#         # context.add_source(source)
#         # raise Pod::Informative.exception "cache proxy source: `#{source_name}` does not exist." unless CPSH.check_proxy_source_exists(source_name)
#     # end
#     return unless (proxy_name= options['proxy'])
#     Pod::UI.message "proxy_name: #{proxy_name}"
# end

Pod::HooksManager.register('cocoapods-cache-proxy', :source_provider) do |context, options|
    show_output = Pod::Config.instance.verbose?
    Pod::UI.message 'cocoapods-cache-proxy received source_provider hook' if show_output
    # Pod::UI.message "master_repo_dir: #{Pod::Config.instance.sources_manager.master_repo_dir}"
    
    # return unless (sources = options['sources'])
    # sources.each do |source_name|
        # Pod::UI.message "source_name: #{source_name}"
        # source = create_source_from_name(source_name)
        # context.add_source(source)
        # raise Pod::Informative.exception "cache proxy source: `#{source_name}` does not exist." unless CPSH.check_proxy_source_exists(source_name)
    # end
    return unless (proxy_name= options['proxy'])
    raise Pod::Informative.exception "cache proxy source: `#{proxy_name}` does not exist." unless CPSH.check_cache_proxy_source_conf_exists(proxy_name)
    Pod::UI.message "proxy_name: #{proxy_name}" if show_output
    Pod::Config.instance.set_cache_proxy_source(proxy_name)
end


def create_source_from_name(source_name)
    repos_dir = Pod::Config.instance.repos_dir
    repo = repos_dir + source_name

    # Pod::UI.message "#{CPSH.get_cache_proxy_source_conf_path(source_name)}\n"

    # if File.exist?(CPSH.get_cache_proxy_source_conf_path(source_name))
    #     url = File.read(CPSH.get_cache_proxy_source_conf_path(source_name))
    #     Pod::CacheSource.new(CPSH.get_cache_proxy_source_root_dir(source_name), url)
    # elsif Dir.exist?("#{repo}")
    #     Pod::CacheSource.new(repo, '');
    # else
    #  raise Pod::Informative.exception "repo #{source_name} does not exist."
    # end

    if Dir.exist?("#{repo}")
        url = ''
        if File.exist?("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
          hash = YAML.load_file("#{repo}/#{CPSH.get_cache_proxy_source_conf_file_name()}")
          url = hash['url']
        end
        Pod::CacheSource.new(repo, url);
    else
     raise Pod::Informative.exception "repo #{source_name} does not exist."
    end
end

# module Pod
#     class Installer
#         class Analyzer

#           alias_method :orig_sources, :sources

#           def sources
#             if podfile.sources.empty? && podfile.plugins.keys.include?('cocoapods-cache-proxy')
#               sources = Array.new
#               plugin_config = podfile.plugins['cocoapods-cache-proxy']
#               # all sources declared in the plugin clause
#               plugin_config['sources'].uniq.map do |name|
#                 sources.push(create_source_from_name(name))
#               end
#               @sources = sources
#             else
#               orig_sources
#             end
#           end
#         end
#     end
# end

# module Pod
#     class Source
#         class Manager

#           alias_method :orig_source_from_path, :source_from_path
          
#           # @return [Source] The Source at a given path.
#           #
#           # @param [Pathname] path
#           #        The local file path to one podspec repo.
#           #
#           def source_from_path(path)
#             @sources_by_path ||= Hash.new do |hash, key|
#               hash[key] = if key.basename.to_s == Pod::TrunkSource::TRUNK_REPO_NAME
#                             TrunkSource.new(key)
#                           elsif File.exist?(CPSH.get_cache_proxy_source_conf_path(key.basename))
#                             create_source_from_name(key.basename)
#                           elsif (key + '.url').exist?
#                             CDNSource.new(key)
#                           else
#                             Source.new(key)
#                           end
#             end
#             @sources_by_path[path]
#           end

#         end
#     end
# end