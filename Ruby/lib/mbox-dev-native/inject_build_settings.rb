require 'cocoapods/target/build_settings'
module Pod
  class Target
    class BuildSettings
      class AggregateTargetSettings

        # Remove all '-framework xxx'
        define_build_settings_method :other_ldflags, :build_setting => true, :memoized => true do
          ld_flags = []
          libraries.each { |l| ld_flags << %(-l"#{l}") }
          weak_frameworks.each { |f| ld_flags << '-weak_framework' << %("#{f}") }
          if td = Config.instance.podfile.target_definitions[target.target_definition.name]
            td.dependencies.each do |dependency|
              if pt = target.pod_targets.find { |t| t.name == dependency.name }
                ld_flags << '-framework' << %("#{pt.product_basename}")
              end
            end
          end
          ld_flags
        end

        define_build_settings_method :always_embed_swift_standard_libraries, :build_setting => true, :memoized => true do
          'NO'
        end

        define_build_settings_method :install_path, :build_setting => true, :memoized => true do
          "$(MBOX_MODULE_NAME:default=$(MBOX_PACKAGE_NAME:default=$(PROJECT_NAME)))"
        end

        define_build_settings_method :skip_install, :build_setting => true, :memoized => true do
          'NO'
        end

        define_build_settings_method :deployment_location, :build_setting => true, :memoized => true do
          'YES'
        end

        define_build_settings_method :deployment_postprocessing, :build_setting => true, :memoized => true do
          'YES'
        end

        define_build_settings_method :dstroot, :build_setting => true, :memoized => true do
          "$(PODS_PODFILE_DIR_PATH)/build"
        end

        define_build_settings_method :strip_installed_product, :build_setting => true, :memoized => true do
          'NO'
        end

        define_build_settings_method :other_swift_flags, :build_setting => true, :memoized => true do
          flags = super() || []
          flags.concat %w(-Xfrontend -enable-dynamic-replacement-chaining)
          flags.concat %w(-Xfrontend -module-interface-preserve-types-as-written)
          flags
        end

        define_build_settings_method :swift_compilation_mode, :build_setting => true, :memoized => true do
          "singlefile"
        end

        define_build_settings_method :dependent_targets, :memoized => true do
          dependent_targets = target.pod_targets.dup
          dependent_targets.concat dependent_targets.flat_map { |pod_target| pod_target.recursive_dependent_targets(:configuration => @configuration) }
          dependent_targets.uniq
        end

        define_build_settings_method :application_framework_search_paths, :memoized => true do
          all_paths = []
          depend_pods = dependent_targets.map(&:specs).flatten.map { |spec| Specification.root_name(spec.name) }.uniq
          Config.instance.mbox_module_native_bundle_paths.each do |name, mbox_bundle_path|
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

        alias_method :mbox_dev_framework_search_paths_0315, :_raw_framework_search_paths
        def _raw_framework_search_paths
          paths = mbox_dev_framework_search_paths_0315.dup
          paths.concat dependent_targets.flat_map { |pt| pt.build_settings[@configuration].framework_search_paths_to_import }
          paths.uniq
        end
      end
    end
  end
end
