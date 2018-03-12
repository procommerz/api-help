# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_help/version'

Gem::Specification.new do |spec|
  spec.name          = "api_help"
  spec.version       = ApiHelp::VERSION
  spec.authors       = ["Denis Kolesnichenko"]
  spec.email         = ["denis@farmy.ch"]

  spec.summary       = %q{This component makes it easier to add interactive IRB documentation and hints to your code}
  spec.description   = %q{This component makes it easier to add interactive IRB documentation and hints to your code}
  spec.homepage      = "https://github.com/procommerz/api-help"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to https://github.com/procommerz/api-help"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rails", "~> 4.2.5"
  spec.add_development_dependency "colorize", "~> 0.8.1"
end
