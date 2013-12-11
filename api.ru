DATAFILE = './var/data.pstore'
WORDFILE = './share/words.txt' # Can generate with "aspell dump master"
LOG = './var/api.log'

require 'rubygems'
require 'bundler/setup'

require './lib/apiapp'
require './lib/linkerapi'
run APIApp.new(LinkerAPI, DATAFILE, WORDFILE, log: Logger.new(LOG))
