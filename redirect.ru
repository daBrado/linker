API_URI = 'http://localhost:6313/'
LOG = './var/redirect.log'
PROXY_IP = '128.120.144.61'

require 'rubygems'
require 'bundler/setup'

module RequestProxyIp; def trusted_proxy?(ip); super || ip == PROXY_IP; end; end
module Rack; class Request; prepend RequestProxyIp; end; end

require './lib/redirectapp'
run RedirectApp.new(API_URI, log: Logger.new(LOG))
