#
# LinkerAPI
#
# A web API for managing redirector links.
#

require_relative './linkstore'

class LinkerAPI
  GET = [:get]
  POST = [:create]
  def initialize(datafile, wordfile, log:nil)
    @linkstore = LinkStore.new datafile, words: File.open(wordfile)
    @log = log
  end
  def get(id)
    @linkstore.get id
  end
  def create(uri:nil,embed:nil)
    id = @linkstore.create(uri, embed:embed)
    @log.info "#{id} #{uri.inspect}"
    id
  end
end
