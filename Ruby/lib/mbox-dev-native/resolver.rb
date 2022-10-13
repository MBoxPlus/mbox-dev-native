
module Pod
  class Resolver
    alias_method :mbox_dev_specifications_for_dependency_1201, :specifications_for_dependency
    def specifications_for_dependency(dependency, additional_requirements = [])
      begin
        mbox_dev_specifications_for_dependency_1201(dependency, additional_requirements)        
      rescue Molinillo::NoSuchDependencyError => e
        if (path = config.mbox_module_specifications[dependency.name]) && 
          (spec = Specification.from_file(path))
          spec = spec.subspec_by_name(dependency.name)
          return [spec] if spec
        end
        raise
      end
    end
  end
end
