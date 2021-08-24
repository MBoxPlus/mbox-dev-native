
module Pod
  class Config
    def mbox_plugin_paths
      @mbox_plugin_paths ||= begin
        if paths = ENV["MBOX_PLUGIN_PATHS"]
          Hash[JSON.parse(paths).map { |k, path| [k, Pathname.new(path)] }]
        else
          []
        end
      end
    end

    def mbox_plugin_native_bundle_paths
      @mbox_plugin_native_bundle_paths ||= begin
        if paths = ENV["MBOX_PLUGIN_NATIVE_BUNDLE_PATHS"]
          Hash[JSON.parse(paths).map { |k, path| [k, Pathname.new(path)] }]
        else
          []
        end
      end
    end

    def mbox_plugin_native_bundle_path(name)
      mbox_plugin_native_bundle_paths[name]
    end

    def mdev_cli_name
      "MDevCLI"
    end

    def mdev_cli_path
      @mdev_cli_path ||= begin
        if path = mbox_plugin_native_bundle_path("MBoxCore")
          path + mdev_cli_name
        else
          nil
        end
      end
    end

  	def mbox_plugin_specifications
  		@mbox_plugin_specifications ||= begin
        mbox_plugin_native_bundle_paths.each do |name, bundle_path|
          spec_path = bundle_path + "#{name}.podspec.json"
          next if spec_path.exist?

          spec_ori_path = mbox_plugin_paths[name] + "Native/#{name}.podspec"
          ipc_script = mbox_plugin_native_bundle_path("MBoxDevNative") + "MBoxDevNative.framework/Resources/spec_ipc.rb"
          puts "SPEC_ORIGIN_PATH='#{spec_ori_path}' SPEC_TARGET_PATH='#{spec_path}' bundle exec ruby '#{ipc_script}'"
          `SPEC_ORIGIN_PATH='#{spec_ori_path}' SPEC_TARGET_PATH='#{spec_path}' bundle exec ruby '#{ipc_script}'`
        end
        mbox_plugin_native_bundle_paths
  		end
  	end
  end
end
