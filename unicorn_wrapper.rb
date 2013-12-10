#!/usr/bin/ruby

Dir.chdir File.dirname(__FILE__)
ENV['BUNDLE_GEMFILE'] = File.join File.dirname(__FILE__), 'Gemfile'

require 'rubygems'
require 'bundler/setup'
require 'unicorn/launcher'

ENV['UNICORN_FD'] = ENV['UPSTART_FDS']
app = Unicorn.builder('config.ru', nil)
Unicorn::HttpServer.new(app, {}).start.join
