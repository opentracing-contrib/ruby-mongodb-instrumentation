
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mongodb/instrumentation/version"

Gem::Specification.new do |spec|
  spec.name          = "signalfx-mongodb-instrumentation"
  spec.version       = Mongodb::Instrumentation::VERSION
  spec.authors       = ["Ashwin Chandrasekar"]
  spec.email         = ["achandrasekar@signalfx.com"]

  spec.summary       = %q{Instrumentation for MongoDB}
  spec.description   = %q{OpenTracing auto-instrumentation for applications using the MongoDB Ruby driver.}
  spec.homepage      = "http://github.com/signalfx/ruby-mongodb-instrumentation"
  spec.license       = "Apache-2.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "opentracing", "~> 0.3"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "signalfx_test_tracer", "~> 0.1.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "appraisal", "~> 2.2"
  spec.add_development_dependency "mongo", "~> 2.6.2"
end
