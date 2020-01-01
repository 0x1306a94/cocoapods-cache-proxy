# require 'cocoapods'

# module Pod
#     class Resolver
#         # >= 1.4.0 才有 resolver_specs_by_target 以及 ResolverSpecification
#         # >= 1.5.0 ResolverSpecification 才有 source，供 install 或者其他操作时，输入 source 变更
#         #
#         if Pod.match_version?("~> 1.4")
#             old_resolver_specs_by_target = instance_method(:resolver_specs_by_target)
#             define_method(:resolver_specs_by_target) do
#                 specs_by_target = old_resolver_specs_by_target.bind(self).call()
#                 # UI.message "specs_by_target: #{specs_by_target}"
#                 # UI.message "specs_by_target:"
#                 specs_by_target.each do |target, rspecs|
#                     # if !rspecs.empty?
#                     #     UI.message "rspecs: #{rspecs}\n"
#                     #     res = rspecs.first
#                     #     UI.message "res: #{res}\n"
#                     #     root_spec = res.spec.root
#                     #     UI.message "specs_by_target root_spec name: #{root_spec.name}"
#                     #     UI.message "specs_by_target root_spec version: #{root_spec.version}"
#                     #     UI.message "specs_by_target origin source: #{root_spec.source}"
#                     # end
#                     rspecs.each do |spec|
#                         # spec.spec.source = { :http => 'http://127.0.0.1:9898/static/AFNetworking.zip'}
#                         root_spec = spec.spec.root
#                         UI.message "spec source: #{root_spec.source}"
#                         UI.message "spec name: #{root_spec.name}"
#                         UI.message "spec version: #{root_spec.version}"
#                     end
#                     # TODO
#                     # 查找缓存代理, 如果命中 则修改地址为 缓存代理地址 
#                     # specs_by_target[target] =  rspecs.map do |spec|
#                     #     spec.spec.source = { :http => 'http://127.0.0.1:9898/static/AFNetworking.zip'}
#                     #     spec
#                     # end
#                 end
#                 # exit 0
#             end
#         end
#     end
# end


# module Pod
#     class Source
#         class Manager

#         #   alias_method :orig_source_from_path, :source_from_path
          
#           # @return [Source] The Source at a given path.
#           #
#           # @param [Pathname] path
#           #        The local file path to one podspec repo.
#           #
#         #   def source_from_path(path)
#         #     # @sources_by_path ||= Hash.new do |hash, key|
#         #     #   art_repo = "#{UTIL.get_repos_art_dir()}/#{key.basename}"
#         #     #   hash[key] = if key.basename.to_s == Pod::TrunkSource::TRUNK_REPO_NAME
#         #     #                 TrunkSource.new(key)
#         #     #               elsif File.exist?("#{art_repo}/.artpodrc")
#         #     #                 create_source_from_name(key.basename)
#         #     #               else
#         #     #                 Source.new(key)
#         #     #               end
#         #     # end
#         #     # @sources_by_path[path]
#         #     orig_source_from_path(path)
#         #     UI.message "source_from_path: #{path}"
#         #     UI.message "sources_by_path: #{@sources_by_path}"
#         #   end

#         end
#     end
# end