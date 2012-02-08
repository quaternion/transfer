# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "transfer/version"

Gem::Specification.new do |s|
  s.name        = "transfer"
  s.version     = Transfer::VERSION
  s.authors     = ["Andrew Nikolaev"]
  s.email       = ["pkskynet@tut.by"]
  s.homepage    = "http://github.com/quaternion/transfer"
  s.summary     = "Transfer data from source database to models"
  s.description = %q{Transfer data from any source database, supported Sequel, to ActiveRecord, Sequel or Mongoid models}

  s.rubyforge_project = "transfer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "sequel"
  # s.add_runtime_dependency "progressbar"

  s.add_development_dependency "rr"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "mongoid"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "bson_ext"
  s.add_development_dependency "ruby-debug-ide19"
end
