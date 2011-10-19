#!/usr/bin/env ruby

require 'rubygems'
require 'RubyCron'
include RubyCron

if ARGV.empty? || ARGV.size > 1 
  $stderr.puts "## Usage: rcjrunner.rb <rubycronjob>"
else
  instance_eval File.read(ARGV[0])
end
