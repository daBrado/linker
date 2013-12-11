API_URI = 'http://localhost:6313/'
LOG = './var/redirect.log'

require 'rubygems'
require 'bundler/setup'

require './lib/redirectapp'
run RedirectApp.new(API_URI, log: Logger.new(LOG))
