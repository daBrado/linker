#
# LinkerAPI
#
# A web API for managing redirector links.
#

require_relative './linkstore'

class LinkerAPI
  def self.allowed_method?(method, cmd)
    case method
      when 'GET'; [:get].include? cmd
      when 'POST'; [:create].include? cmd
    end
  end
  def initialize(datafile, wordfile, log:nil)
    @linkstore = LinkStore.new datafile, words: File.open(wordfile)
    @log = log
  end
  def get(id)
    @linkstore.get id
  end
  def create(uri:nil)
    id = @linkstore.create uri
    @log.info "#{id} #{uri.inspect}"
    id
  end
end
