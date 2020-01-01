# require 'cocoapods-downloader'
# require 'cocoapods'

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
#                 Pod::UI.message "spec: #{spec}"
#                 Pod::UI.message "source: #{source}"
#                 Pod::UI.message "destination: #{destination}"
#                 Pod::UI.message "destination parent: #{destination.parent}"
#                 Pod::UI.message "destination parent basename: #{destination.basename}"
#                 # p = "/Users/king/Desktop/Test"
#                 # FileUtils.rm_rf(p)
#                 # FileUtils.cp_r(source, p)
#                 # exit 0
#                 orig_copy_and_clean(source, destination, spec)
#                 # exit 0
#             end
#         end
#     end
# end