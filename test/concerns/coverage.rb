require "simplecov"
require "coveralls"
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.root(File.expand_path("../../lib", __FILE__))
SimpleCov.start
