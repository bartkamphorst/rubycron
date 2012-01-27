#!/usr/bin/env ruby

require 'rubygems'
require 'rubycron'
include RubyCron

if ARGV[0]
  instance_eval File.read(ARGV[0])
else
  $stderr.puts "## Usage: rcjrunner.rb <rubycronjob>"
end
