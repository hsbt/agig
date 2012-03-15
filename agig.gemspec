# -*- encoding: utf-8 -*-
require File.expand_path('../lib/agig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SHIBATA Hiroshi"]
  gem.email         = ["shibata.hiroshi@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "agig"
  gem.require_paths = ["lib"]
  gem.version       = Agig::VERSION

  gem.add_dependency 'net-irc', ['>= 0']
  gem.add_dependency 'libxml-ruby', ['>= 0']
end
