# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dir_model/version'

Gem::Specification.new do |spec|
  spec.name          = "dir_model"
  spec.version       = DirModel::VERSION
  spec.authors       = ["Steve Chung"]
  spec.email         = ["hello@stevenchung.ca"]

  spec.summary       = "Import and export directories with an ORM-like interface."
  spec.homepage      = "https://github.com/FinalCAD/dir_model"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport',       '>= 4.2'
  spec.add_dependency 'activemodel',         '>= 4.2'
  spec.add_dependency 'inherited_class_var', '1.0.0.beta1'
  spec.add_dependency 'fastimage',           '~> 1.8'
end
