API_URI = 'http://localhost:6313/'
LOG = './var/linkerapp.log'

require 'rubygems'
require 'bundler/setup'

require './lib/linkerapp'
run LinkerApp.new(API_URI, log: Logger.new(LOG))
