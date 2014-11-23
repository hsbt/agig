require 'bundler/setup'
require 'webmock/rspec'
require 'pry-byebug'

require 'agig'

def spec_path
  File.dirname(__FILE__)
end

def fixture_path
  spec_path + '/fixtures'
end

require 'coveralls'
Coveralls.wear!
