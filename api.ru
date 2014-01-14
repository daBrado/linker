DATAFILE = './var/links.pstore'
WORDFILE = './share/words.txt' # Can generate with "aspell dump master"
LOG = './var/api.log'
PROXY_IP = '128.120.144.61'

require 'rubygems'
require 'bundler/setup'

module RequestProxyIp; def trusted_proxy?(ip); super || ip == PROXY_IP; end; end
module Rack; class Request; prepend RequestProxyIp; end; end

require './lib/linkerapi'
run RackService::App.new(LinkerAPI, DATAFILE, WORDFILE, log: Logger.new(LOG))
