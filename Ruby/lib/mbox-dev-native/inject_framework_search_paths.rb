require 'cocoapods/target/build_settings'
module Pod
  class Target
    class BuildSettings
      class AggregateTargetSettings

        define_build_settings_method :application_framework_search_paths, :memoized => true do
          all_paths = []
          depend_pods = pod_targets.map(&:specs).flatten.map { |spec| Specification.root_name(spec.name) }.uniq
          Config.instance.mbox_plugin_native_bundle_paths.each do |name, mbox_bundle_path|
            next unless MBox::Config.instance.development_pods[name].blank?
            next unless depend_pods.include?(name)
            paths = Dir[mbox_bundle_path + "*.framework"]
            while !paths.empty?
              path = paths.shift
              dir = File.dirname(path)
              all_paths << dir unless all_paths.include?(dir)
              paths.concat Dir[path + "/Versions/A/Frameworks/*.framework"]
            end
          end
          all_paths.sort
        end

        def merge_spec_xcconfig_into_xcconfig(spec_xcconfig_hash, xcconfig)
          xcconfig = super(spec_xcconfig_hash, xcconfig)
          xcconfig.attributes.delete("OTHER_CFLAGS")
          xcconfig.attributes.each do |name, value|
            xcconfig.attributes[name] = value.shellsplit.map do |v|
              next v unless v.start_with?("${PODS_ROOT}/")
              path = v.sub("${PODS_ROOT}", target.sandbox.root.to_s)
              path = Pathname(path).cleanpath.to_s
              next v unless application_framework_search_paths.include?(path)
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
