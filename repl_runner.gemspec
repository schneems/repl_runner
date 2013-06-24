# -*- encoding: utf-8 -*-
require File.expand_path('../lib/repl_runner/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Richard Schneeman"]
  gem.email         = ["richard@heroku.com"]
  gem.description   = %q{ Programatically drive REPL like interfaces, irb, bash, etc. }
  gem.summary       = %q{ Run your REPL like interfaces like never before}
  gem.homepage      = "https://github.com/schneems/repl_runner"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "repl_runner"
  gem.require_paths = ["lib"]
  gem.version       = ReplRunner::VERSION
  gem.license       = 'MIT' # the Georgia Tech of the North

  gem.add_dependency "activesupport"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "mocha"
end
