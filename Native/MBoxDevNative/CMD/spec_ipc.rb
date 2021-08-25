#encoding: utf-8
#!/usr/bin/ruby

require 'fileutils'
require 'ostruct'

Encoding.default_external = 'UTF-8'

def err(msg)
    puts "\terror: " + msg
    exit 1
end

def warn(msg)
    puts "\twarning: " + msg
end

def note(msg)
    puts "\t" + msg
end

envvars = %w(
             SPEC_ORIGIN_PATH
             SPEC_TARGET_PATH

             SPEC_VERSION
             SPEC_HOMEPAGE
             SPEC_SOURCE_GIT
             SPEC_SOURCE_COMMIT
             )

envvars.each do |var|
    Kernel.const_set(var, ENV[var])
end

note SPEC_ORIGIN_PATH

require 'cocoapods-core'
spec = Pod::Specification.from_file(SPEC_ORIGIN_PATH)
root_name = spec.name
spec.version = SPEC_VERSION if SPEC_VERSION
spec.homepage = SPEC_HOMEPAGE if SPEC_HOMEPAGE
if SPEC_SOURCE_COMMIT
    git = SPEC_SOURCE_GIT || spec.source[:git]
    spec.source = {
        :git => git,
        :commit => SPEC_SOURCE_COMMIT
    }
end

specs = spec.subspecs.blank? ? [spec] : spec.subspecs
Dir.chdir(File.dirname(SPEC_TARGET_PATH)) do
    specs.each do |spec|
        framework_name = spec.name.gsub("/", "")
        framework_name = root_name if framework_name == "#{root_name}Default"
        framework_name += ".framework"
        spec.vendored_frameworks = framework_name
        spec.source_files = []

        user_target_xcconfig = spec.attributes_hash["user_target_xcconfig"] || {}
        user_target_xcconfig.delete("FRAMEWORK_SEARCH_PATHS")
        spec.user_target_xcconfig = user_target_xcconfig
    end
    note "Write to `#{SPEC_TARGET_PATH}`"
    File.write(SPEC_TARGET_PATH, spec.to_pretty_json)
end
