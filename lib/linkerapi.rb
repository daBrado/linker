#
# LinkerAPI
#
# A web API for managing redirector links.
#

require_relative 'linkstore'
require_relative '../vendor/rackservice/rackservice'

class LinkerAPI < RackService::API
  def initialize(datafile, wordfile, log:Logger.new(STDERR))
    @linkstore = LinkStore.new datafile, words: File.open(wordfile)
    @log = log
  end
  def get(id)
    @linkstore.get id
  end
  post
  def create(uri:nil, reusable:true)
    id = @linkstore.create uri, reusable:reusable
    @log.info "#{id} #{uri.inspect}"
    id
  end
end
