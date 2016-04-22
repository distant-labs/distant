
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
SimpleCov.minimum_coverage 100

require 'rspec'
require 'byebug'
require 'bundler/setup'
require 'webmock/rspec'
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'distant'
require 'distant/rspec'
