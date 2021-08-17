require 'cocoapods/target/build_settings'
module Pod
  class Target
    class BuildSettings
      class AggregateTargetSettings
        define_build_settings_method :mbox_plugins_root, :build_setting => true, :memoized => true do
          Config.instance.mbox_plugins_path.to_s
        end

        def application_framework_search_paths
          @application_framework_search_paths ||= begin
            paths = Dir[mbox_plugins_root + "/*/*.framework"]
            all_paths = []
            while !paths.empty?
              path = paths.shift
              dir = File.dirname(path).sub(mbox_plugins_root.to_s, "${MBOX_PLUGINS_ROOT}")
              all_paths << dir unless all_paths.include?(dir)
              paths.concat Dir[path + "/Versions/A/Frameworks/*.framework"]
            end
            all_paths.sort
          end
        end

        def merge_spec_xcconfig_into_xcconfig(spec_xcconfig_hash, xcconfig)
          xcconfig = super(spec_xcconfig_hash, xcconfig)
          xcconfig.attributes.delete("OTHER_CFLAGS")
          xcconfig.attributes.each do |name, value|
            xcconfig.attributes[name] = value.shellsplit.map do |v|
              next v unless v.start_with?("${PODS_ROOT}/")
              path = v.sub("${PODS_ROOT}", target.sandbox.root.to_s)
              path = Pathname(path).cleanpath.to_s
              next v unless path.start_with?(mbox_plugins_root.to_s)
              nil
            end.compact.join(" ")
          end
          xcconfig = super(
            {"FRAMEWORK_SEARCH_PATHS" => application_framework_search_paths.map { |p| "\"#{p}\"" }.join(" ")}, xcconfig)
          xcconfig
        end

      end
    end
  end
end
