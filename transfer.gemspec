# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "transfer/version"

Gem::Specification.new do |s|
  s.name        = "transfer"
  s.version     = Transfer::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "transfer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rr"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "mongoid"
  s.add_development_dependency "bson_ext"

  s.add_development_dependency "ruby-debug-ide19"
  s.add_runtime_dependency "progressbar"
  s.add_runtime_dependency "sequel"
end
