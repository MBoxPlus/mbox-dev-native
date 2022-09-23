
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "mbox-dev-native/version"

Gem::Specification.new do |spec|
  spec.name          = "mbox-dev-native"
  spec.version       = MBoxDevNative::VERSION
  spec.authors       = [`git config user.name`.strip]
  spec.email         = [`git config user.email`.strip]

  spec.summary       = %q{Plugin for MBox.}
  spec.description   = %q{Plugin for MBox.}
  spec.homepage      = "https://github.com/mbox/mbox-dev-native"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  # spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_dependency "mbox"
  spec.add_dependency "mbox-cocoapods"
  spec.add_dependency "cocoapods", ">= 1.9.0"
end
