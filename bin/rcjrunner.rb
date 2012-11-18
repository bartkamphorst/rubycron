#!/usr/bin/env ruby

require 'rubygems'
require 'rubycron'
include RubyCron
require 'optparse'

banner = "## Usage: rcjrunner.rb <rubycronjob> [args..]"
OptionParser.new do |opts|
  opts.banner = banner
end.parse!

if ARGV[0]
  rcjfile = ARGV.shift
  instance_eval(File.read(rcjfile)) if File.exists?(rcjfile)
else
  $stderr.puts banner
end
