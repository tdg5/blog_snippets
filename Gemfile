source "https://rubygems.org"

gemspec

gem "pry"
gem "redcarpet", :platform => %w[mri]
gem "ruby-wpdb", :git => "https://github.com/tdg5-wordpress/ruby-wpdb.git", :branch => :master

group :test do
  gem "coveralls", :require => false
  gem "guard"
  gem "guard-minitest"
  gem "minitest", ">= 3.0"
  gem "mocha"
  gem "simplecov", :require => false
end
