require 'rubygems'

$:.push File.expand_path("../lib", __FILE__)
require "rubycron/version"

Gem::Specification.new do |s|
  s.name              = "rubycron"
  s.summary           = "Simplifies your Ruby cronjobs by automating the reporting process."
  s.description       = "Write clean cronjobs in Ruby, and get reporting for free!"
  s.version           = RubyCron::VERSION
  s.author            = "Bart Kamphorst"
  s.email             = "rubycron@kamphorst.com"
  s.homepage          = "https://github.com/bartkamphorst/rubycron"
  s.require_paths     = ["lib"]
  s.files             = ["README.md", "Gemfile", "lib/rubycron.rb", "lib/rubycron/errors.rb", "lib/rubycron/main.rb", "lib/rubycron/report.erb", "lib/rubycron/version.rb", "sample/test.rcj", "bin/rcjrunner.rb"]
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]
  s.executables       = ["rcjrunner.rb"]
  s.license	      = "Modified BSD"  

  s.add_dependency("mail", ">= 2.6")
  s.add_development_dependency("simplecov", "~> 0.7.1")
  s.add_development_dependency("rspec", "~> 3.4")
  
end
