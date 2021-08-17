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
             PRODUCT_DIR
             SPEC_VERSION
             SPEC_HOMEPAGE
             SPEC_SOURCE_GIT
             SPEC_SOURCE_COMMIT
             SPEC_ORIGIN_PATH
             SPEC_TARGET_PATH
             )

envvars.each do |var|
    Kernel.const_set(var, ENV[var])
end

podspec_path = File.join(SPEC_ORIGIN_PATH)
note podspec_path

require 'cocoapods-core'
spec = Pod::Specification.from_file(podspec_path)
root_name = spec.name
spec.version = SPEC_VERSION
spec.homepage = SPEC_HOMEPAGE if SPEC_HOMEPAGE
git = SPEC_SOURCE_GIT || spec.source[:git]
spec.source = {
    :git => git,
    :commit => SPEC_SOURCE_COMMIT
}

specs = spec.subspecs.blank? ? [spec] : spec.subspecs
Dir.chdir(PRODUCT_DIR) do
    specs.each do |spec|
        framework_name = spec.name.gsub("/", "")
        framework_name = root_name if framework_name == "#{root_name}Default"
        framework_name += ".framework"
        spec.vendored_frameworks = framework_name

        spec.source_files = []
    end
    note "Write to `#{SPEC_TARGET_PATH}`"
    File.write(SPEC_TARGET_PATH, spec.to_pretty_json)
end
