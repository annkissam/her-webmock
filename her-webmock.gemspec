# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'her/webmock/version'

Gem::Specification.new do |spec|
  spec.name          = "her-webmock"
  spec.version       = Her::WebMock::VERSION
  spec.authors       = ["Octavian Neamtu"]
  spec.email         = ["octavian.neamtu@annkissam.com"]

  spec.summary       = %q{Easier request stubbing for Her::Model with webmock.}
  spec.homepage      = "https://github.com/annkissam/her-webmock.git"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "her", ">= 0.8.1"
  spec.add_runtime_dependency "webmock"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
