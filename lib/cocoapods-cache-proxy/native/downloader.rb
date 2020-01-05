require 'cocoapods-downloader'
require 'cocoapods'

# module Pod
#     module Downloader
#         class Cache
#             alias_method :orig_copy_and_clean, :copy_and_clean
#             def copy_and_clean(source, destination, spec)
#                 # specs_by_platform = group_subspecs_by_platform(spec)
#                 # destination.parent.mkpath
#                 # FileUtils.rm_rf(destination)
#                 # FileUtils.cp_r(source, destination)
#                 # Pod::Installer::PodSourcePreparer.new(spec, destination).prepare!
#                 # Sandbox::PodDirCleaner.new(destination, specs_by_platform).clean!
#                 Pod::UI.message "copy_and_clean: \n"
#                 Pod::UI.message "spec: #{spec.class}"
#                 Pod::UI.message "source: #{source}"
#                 Pod::UI.message "destination: #{destination}"
#                 Pod::UI.message "destination parent: #{destination.parent}"
#                 Pod::UI.message "destination parent basename: #{destination.basename}"
#                 p = "/Users/king/Desktop/#{source.basename}"
#                 FileUtils.rm_rf(p)
#                 FileUtils.cp_r(source, p)
#                 # exit 0
#                 orig_copy_and_clean(source, destination, spec)
#                 # exit 0
#             end
#         end
#     end
# end

module Pod
  module Downloader
    class Http

      alias_method :orig_download_file, :download_file

      def download_file(full_filename)
        Pod::UI.message "full_filename: #{full_filename}" if Pod::Config.instance.verbose?
        
        proxy_source = Pod::Config.instance.cache_proxy_source
        download_uri = URI(url)
        proxy_source_uri = URI(proxy_source.baseURL)
        
        Pod::UI.message "url: #{download_uri.path}" if Pod::Config.instance.verbose?
        Pod::UI.message "proxy_source baseURL: #{proxy_source.baseURL}" if Pod::Config.instance.verbose?
        if download_uri.path.start_with?(proxy_source_uri.path) 
            curl_options = []
            curl_options.concat(["-u", "#{proxy_source.user}:#{proxy_source.password}"]) unless proxy_source.user.blank? && proxy_source.password.blank?
            curl_options.concat(["-f", "-L", "-o", full_filename, url, "--create-dirs"])
            Pod::UI.message "curl_options: #{curl_options.join(" ")}" if Pod::Config.instance.verbose?
            curl! curl_options
        else
          orig_download_file(full_filename)
        end
      end
    end
  end
end