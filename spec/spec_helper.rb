require 'bundler/setup'
require 'agig'
require 'webmock/rspec'

def spec_path
  File.dirname(__FILE__)
end

def fixture_path
  spec_path + '/fixtures'
end

require 'coveralls'
Coveralls.wear!
