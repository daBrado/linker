BASEDIR = File.absolute_path "#{File.dirname __FILE__}"
DATAFILE = "#{BASEDIR}/var/data.pstore"
WORDFILE = "#{BASEDIR}/share/words.txt" # Can generate with "aspell dump master"
LOG = "#{BASEDIR}/var/api.log"

require "#{BASEDIR}/lib/apiapp"
require "#{BASEDIR}/lib/linkerapi"

run APIApp.new(
  LinkerAPI, DATAFILE, WORDFILE,
  log: Logger.new(LOG)
)
