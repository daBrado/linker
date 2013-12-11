BASEDIR = File.absolute_path "#{File.dirname __FILE__}"
API_URI = "http://localhost:6313/"
LOG = "#{BASEDIR}/var/redirect.log"

require "#{BASEDIR}/lib/redirectapp"

run RedirectApp.new(API_URI, log: Logger.new(LOG))
