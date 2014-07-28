#
# LinkerAPI
#
# A web API for managing redirector links.
#

require_relative 'linkstore'
require_relative '../vendor/rackservice/rackservice'

class LinkerAPI < RackService::API
  def initialize(datafile, wordfile, reusable:true, log:Logger.new(STDERR))
    @linkstore = LinkStore.new datafile, words: File.open(wordfile)
    @reusable = reusable
    @log = log
  end
  def get(id)
    @linkstore.get id
  end
  post
  def create(uri:nil, reusable:nil)
    reusable = case reusable
      when nil then @reusable
      when 'false' then false
      when 'true' then true
      else reusable
    end
    id = @linkstore.create uri, reusable:reusable
    @log.info "#{id} #{uri.inspect}"
    id
  end
end
