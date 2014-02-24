# -*- encoding: utf-8 -*-
require File.expand_path('../lib/agig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SHIBATA Hiroshi"]
  gem.email         = ["shibata.hiroshi@gmail.com"]
  gem.description   = %q{another Github IRC Gateway}
  gem.summary       = %q{agig is another Github IRC Gateway. agig is forked from gig.rb, and contained net-irc gems.}
  gem.homepage      = "https://github.com/hsbt/agig"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "agig"
  gem.require_paths = ["lib"]
  gem.version       = Agig::VERSION

  gem.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  gem.add_dependency 'net-irc'
  gem.add_dependency 'faraday', '~> 0.8.7'
  gem.add_dependency 'octokit', '~> 1.25'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'coveralls'
end
