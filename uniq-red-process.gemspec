# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uniq/red_process/version"

require 'bundler'

Gem::Specification.new do |s|
  s.name        = "uniq-red-process"
  s.version     = Uniq::RedProcess::VERSION
  s.authors     = ["Ivan Kasatenko"]
  s.email       = ["sky.31338@gmail.com"]
  s.homepage    = "http://uniqsystems.ru/"
  s.summary     = %q{UNIQ Systems Google Reader Red processor}
  s.description = %q{UNIQ Systems Google Reader Red processor}

  s.rubyforge_project = "uniq-red-process"

  s.files         = `git ls-files`.split("\n").map { |file| 
    file.gsub('"', '').gsub(/\\(\d\d\d)/) { |match|
      [($1[0].to_i*64+$1[1].to_i*8+$1[2].to_i)].pack('c')
    }
  }
  
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
    
  s.add_dependency('GoogleReaderApiUniq', '~> 0.3.7')
  s.add_dependency('launchy', '~> 2.1')
end
