DATAFILE = './var/links.pstore'
WORDFILE = './share/words.txt' # Can generate with "aspell dump master"
LOG = './var/linkerapi.log'

require 'rubygems'
require 'bundler/setup'

require './lib/linkerapi'
run LinkerAPI.new(DATAFILE, WORDFILE, log: Logger.new(LOG))
