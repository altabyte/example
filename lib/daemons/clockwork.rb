#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
require File.join(root, "config", "environment")
clock_path = File.join(File.expand_path(File.dirname(__FILE__)), '../', 'clock.rb')

$running = true
Signal.trap("TERM") do
  $running = false
end

while ($running) do
  STDERR.sync = STDOUT.sync = true
  require clock_path

  trap('INT') do
    puts "\rExiting"
    exit
  end

  Clockwork::run
end