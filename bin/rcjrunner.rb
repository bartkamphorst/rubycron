#!/usr/bin/env ruby

require 'rubygems'
require 'RubyCron'

if ARGV.empty? || ARGV.size > 1 
  $stderr.puts "## Usage: rcjrunner.rb <rubycronjob>"
else
  eval IO.readlines(ARGV[0]).to_s
end
