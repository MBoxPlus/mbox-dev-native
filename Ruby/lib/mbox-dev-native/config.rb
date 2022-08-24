
module Pod
  class Config
    def mbox_plugin_paths
      @mbox_plugin_paths ||= begin
        if paths = ENV["MBOX_PLUGIN_PATHS"]
          Hash[JSON.parse(paths).map { |k, path| [k, Pathname.new(path)] }]
        else
          {}
        end
      end
    end

    def mbox_module_paths
      @mbox_plugin_paths ||= begin
        if paths = ENV["MBOX_MODULE_PATHS"]
          Hash[JSON.parse(paths).map { |k, path| [k, Pathname.new(path)] }]
        else
          {}
        end
      end
    end

    def mbox_module_native_bundle_paths
      @mbox_module_native_bundle_paths ||= begin
        if paths = ENV["MBOX_MODULE_NATIVE_BUNDLE_PATHS"]
          Hash[JSON.parse(paths).map { |k, path| [k, Pathname.new(path)] }]
        else
          {}
        end
      end
    end

    def mbox_module_native_bundle_path(name)
      mbox_module_native_bundle_paths[name]
    end

    def mdev_cli_name
      "MDevCLI"
    end

    def mdev_cli_path
      @mdev_cli_path ||= begin
        if path = mbox_module_native_bundle_path("MBoxCore")
          path + mdev_cli_name
        else
          nil
        end
      end
    end

  	def mbox_module_specifications
  		@mbox_module_specifications ||= begin
        Hash[mbox_module_native_bundle_paths.map do |name, bundle_path|
          spec_name = name.gsub('/', '')
          spec_path = bundle_path + "#{spec_name}.podspec.json"
          unless spec_path.exist?
            spec_ori_path = mbox_module_paths[name] + "Native/#{spec_name}.podspec"
            ipc_script = mbox_module_native_bundle_path("MBoxDevNative") + "MBoxDevNative.framework/Resources/spec_ipc.rb"
            `SPEC_ORIGIN_PATH='#{spec_ori_path}' SPEC_TARGET_PATH='#{spec_path}' bundle exec ruby '#{ipc_script}'`
          end
          [spec_name, spec_path]
        end]
  		end
  	end
  end
end
