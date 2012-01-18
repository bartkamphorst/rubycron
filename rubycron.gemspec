require 'rubygems'

Gem::Specification.new do |s|
  s.name              = "rubycron"
  s.summary           = "Simplifies your Ruby cronjobs by automating the reporting process."
  s.description       = "Write clean cronjobs in Ruby, and get reporting for free!"
  s.version           = "0.2b"
  s.author            = "Bart Kamphorst"
  s.email             = "rubycron@kamphorst.com"
  s.homepage          = "https://github.com/bartkamphorst/rubycron"
  s.require_paths     = ["lib"]
  s.files             = ["README.md", "Gemfile", "lib/rubycron.rb", "lib/report.erb", "sample/test.rcj", "bin/rcjrunner.rb"]
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]
  
  s.add_dependency("mail")
end