# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blog_snippets/version'

Gem::Specification.new do |spec|
  spec.name          = 'blog_snippets'
  spec.version       = BlogSnippets::VERSION
  spec.authors       = ['Danny Guinther']
  spec.email         = ['dannyguinther@gmail.com']
  spec.summary       = %q{Code snippets from my blog.}
  spec.description   = %q{Code snippets from my blog: http://blog.tdg5.com}
  spec.homepage      = 'https://github.com/tdg5/blog_snippets'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
