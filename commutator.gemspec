# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commutator/version'

Gem::Specification.new do |spec|
  spec.name          = "commutator"
  spec.version       = Commutator::VERSION
  spec.authors       = ["Bradley Schaefer", "Ben Kimpel"]
  spec.email         = ["bradley.schaefer@gmail.com"]

  spec.summary       = %q{Model object interface for Amazon DynamoDB.}
  spec.description   = %q{Model object interface for Amazon DynamoDB.}
  spec.homepage      = "https://github.com/tablexi/commutator"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_dependency "activesupport", "~> 4.0"
  spec.add_dependency "activemodel", "~> 4.0"
  spec.add_dependency "aws-sdk", "~> 2.1"
  spec.add_dependency "ice_nine"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
end
