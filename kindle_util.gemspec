# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kindle_util/version'

Gem::Specification.new do |gem|
  gem.name          = "kindle_util"
  gem.version       = KindleUtil::VERSION
  gem.authors       = ["Matt Conway"]
  gem.email         = ["matt@conwaysplace.com"]
  gem.description   = %q{A utility for performing bulk actions against your kindle library, most notably to allow resetting the "last page read" for all your kindle books.}
  gem.summary       = %q{A utility for performing bulk actions against your kindle library}
  gem.homepage      = "http://github.com/wr0ngway/kindle_util"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency("logging")
  gem.add_dependency("highline")
  gem.add_dependency("clamp")
  gem.add_dependency("mechanize")
end
