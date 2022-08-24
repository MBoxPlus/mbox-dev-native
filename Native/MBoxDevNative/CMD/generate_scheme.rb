#encoding: utf-8
#!/usr/bin/ruby

require 'fileutils'
require 'ostruct'
require 'xcodeproj'

Encoding.default_external = 'UTF-8'

def err(msg)
  puts "  error: " + msg
  exit 1
end

def warn(msg)
  puts "  warning: " + msg
end

def note(msg)
  puts "  " + msg
end

envvars = %w(
  WORKSPACE_PATH
  PROJECT_PATHS
)

envvars.each do |var|
  Kernel.const_set(var, ENV[var])
end

module Xcodeproj
  class XCScheme
    class BuildableReference
      def container_path
        container = @xml_element.attributes['ReferencedContainer']
        container.sub(/.*?:/, "") if container
      end

      def container_path=(path)
        @xml_element.attributes['ReferencedContainer'] = "container:#{path}"
      end
    end
  end
end

workspace_scheme_dir = Xcodeproj::XCScheme.shared_data_dir(WORKSPACE_PATH)
FileUtils.mkdir_p(workspace_scheme_dir)
scheme_path = workspace_scheme_dir + "MBoxBuild.xcscheme"
FileUtils.rm_rf(scheme_path)

workspace = Xcodeproj::Workspace.new_from_xcworkspace(WORKSPACE_PATH)

user_projects = PROJECT_PATHS.split(":").map do |path|
  Xcodeproj::Project.open(path)
end
user_targets = user_projects.flat_map(&:native_targets).uniq.sort_by(&:name)

scheme = Xcodeproj::XCScheme.new()
user_targets.each do |user_target|
  note "Add Target `#{user_target.name}` (from `#{user_target.project.path}`)"
  entry = Xcodeproj::XCScheme::BuildAction::Entry.new(user_target).tap do |entry|
    entry.build_for_testing = true
    entry.build_for_running = true
    entry.build_for_profiling = true
    entry.build_for_archiving = true
    entry.build_for_analyzing = true
    path = user_target.project.path.relative_path_from(File.dirname(WORKSPACE_PATH))
    ref = entry.buildable_references.first
    ref.set_reference_target(user_target)
    ref.container_path = path
  end
  scheme.build_action.add_entry(entry)
end

note "Generate `#{scheme_path}`"
scheme.save_as(WORKSPACE_PATH, "MBoxBuild")
