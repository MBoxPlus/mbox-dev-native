
module Pod
  class Installer
    class Analyzer
      alias_method :mbox_dev_dependencies_for_specs, :dependencies_for_specs
      def dependencies_for_specs(specs, platform, all_specs)
        dependent_specs = {
          :debug => Set.new,
          :release => Set.new,
        }

        if !specs.empty? && !all_specs.empty?
          specs.each do |s|
            s.dependencies(platform).each do |dep|
              # Hook to skip
              ss = all_specs[dep.name]
              next if ss.nil?
              ss.each do |spec|
                if spec.non_library_specification?
                  if s.test_specification? && spec.name == s.consumer(platform).app_host_name && spec.app_specification?
                    # This needs to be handled separately, since we _don't_ want to treat this as a "normal" dependency
                    next
                  end
                  raise Informative, "`#{s}` depends upon `#{spec}`, which is a `#{spec.spec_type}` spec."
                end

                dependent_specs.each do |config, set|
                  next unless s.dependency_whitelisted_for_configuration?(dep, config)
                  set << spec
                end
              end
            end
          end
        end

        Hash[dependent_specs.map { |k, v| [k, (v - specs).group_by(&:root)] }].freeze
      end
    end
  end

  class Resolver
    alias_method :mbox_dev_resolver_specs_by_target, :resolver_specs_by_target
    def resolver_specs_by_target
      dev_names = sandbox.development_pods.keys

      # Remove the dependencies for the development repository
      @activated.vertices.each do |name, vertex|
        next unless dev_names.include?(vertex.payload.root.name)
        vertex.outgoing_edges.delete_if { |edge|
          !dev_names.include?(edge.destination.payload.root.name)
        }
      end

      # Select a min dependency graphic
      query_dependencies = @podfile_dependency_cache.podfile_dependencies.map(&:name).uniq
      require_dependencies = []
      while !query_dependencies.empty?
        name = query_dependencies.pop
        require_dependencies << name
        if vertex = @activated.vertices[name]
          vertex.outgoing_edges.map(&:destination).each do |dest|
            dest_name = dest.payload.root.name
            if !require_dependencies.include?(dest_name) && !query_dependencies.include?(dest_name)
              query_dependencies << dest_name
            end
          end
        end
      end

      # Remove unused dependencies
      @activated.vertices.delete_if do |name, _|
        !require_dependencies.include?(name)
      end


      @resolver_specs_by_target ||= {}.tap do |resolver_specs_by_target|
        @podfile_dependency_cache.target_definition_list.each do |target|
          next if target.abstract? && !target.platform

          # can't use vertex.root? since that considers _all_ targets
          explicit_dependencies = @podfile_dependency_cache.target_definition_dependencies(target).map(&:name).to_set

          used_by_aggregate_target_by_spec_name = {}
          used_vertices_by_spec_name = {}

          @activated.tsort.reverse_each do |vertex|
            spec_name = vertex.name
            explicitly_included = explicit_dependencies.include?(spec_name)
            # HOOK: Only link explicitly dependency
            if explicitly_included # || vertex.incoming_edges.any? { |edge| used_vertices_by_spec_name.key?(edge.origin.name) && edge_is_valid_for_target_platform?(edge, target.platform) }
              validate_platform(vertex.payload, target)
              used_vertices_by_spec_name[spec_name] = vertex
              used_by_aggregate_target_by_spec_name[spec_name] = vertex.payload.library_specification? &&
                (explicitly_included || vertex.predecessors.any? { |predecessor| used_by_aggregate_target_by_spec_name.fetch(predecessor.name, false) })
            end
          end

          resolver_specs_by_target[target] = used_vertices_by_spec_name.each_value.
            map do |vertex|
              payload = vertex.payload
              non_library = !used_by_aggregate_target_by_spec_name.fetch(vertex.name)
              spec_source = payload.respond_to?(:spec_source) && payload.spec_source
              ResolverSpecification.new(payload, non_library, spec_source)
            end.
            sort_by(&:name)
        end
      end

    end
  end

  class PodTarget
    alias_method :mbox_framework_paths_0811, :framework_paths
    def framework_paths
      mbox_framework_paths_0811.reject { |name, path|
        name.start_with?("MBox")
      }
    end
  end
end