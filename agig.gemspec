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

  gem.add_dependency 'net-irc'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'certified'
end
