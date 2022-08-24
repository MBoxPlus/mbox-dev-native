require 'yaml'

puts "load dev gem Specification"
module Pod
  class Specification

    def self.mb_find_plugin_package_root(start_path = '.')
      raise "No such path error" unless File.exists?(start_path)

      current_path = File.expand_path(start_path)
      return_path = nil
      until File.directory?(current_path) && File.expand_path(current_path) == File.expand_path(File.join(current_path, '..'))
        manifest_path = File.join(current_path, 'manifest.yml')
        if File.exists?(manifest_path)
          yaml = YAML.load_file(manifest_path) 
          if yaml["VERSION"]
            return_path = current_path
            break
          end
        end
        current_path = File.dirname(current_path)
      end
      return_path
    end

    def self.mb_find_plugin_module_root(start_path = '.')
      raise "No such path error" unless File.exists?(start_path)

      current_path = File.expand_path(start_path)
      return_path = nil
      until File.directory?(current_path) && File.expand_path(current_path) == File.expand_path(File.join(current_path, '..'))
        manifest_path = File.join(current_path, 'manifest.yml')
        if File.exists?(manifest_path)
          return_path = current_path
          break
        end
        current_path = File.dirname(current_path)
      end
      return_path
    end

    alias_method :mbox_dev_dependency, :dependency
    def dependency(*args)
      name, *version_requirements = args
      module_name = name
      if module_name.start_with?("MBox") && module_name.include?("/")
        v = module_name.split("/")
        package_name = v.first
        module_name = v.last
        if !module_name.start_with?(package_name)
          module_name = package_name + module_name
        end
      end
      mbox_dev_dependency(module_name, *version_requirements)
    end

  end

end
