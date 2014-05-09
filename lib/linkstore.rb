#
# Link Store
#
# Use a PStore to create and find mappings between Obfuscated IDs and URIs.
#

require_relative 'obid'
require_relative 'wordishes'

require 'pstore'
require 'uri'

class LinkStore
  IDCHARS = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|r|r.to_a}.reduce(:+)
  IDMINLEN = 4
  IDSEED = Random.new_seed
  WORDMINLEN = 3
  THREAD_SAFE_PSTORE = true
  ULTRA_SAFE_PSTORE = true
  def initialize(file, words: [])
    @wordishes = Wordishes.new(words, WORDMINLEN)
    @store = PStore.new file, THREAD_SAFE_PSTORE
    @store.ultra_safe = ULTRA_SAFE_PSTORE
    @store.transaction do
      if @store.roots.empty?
        @store[:idchars] = IDCHARS
        @store[:idminlen] = IDMINLEN
        @store[:idseed] = IDSEED
        @store[:idnext] = 0
      end
    end
    @mutex = Mutex.new
    @links = {}
  end
  def create(uri, embed:nil)
    if embed != nil
      x = loop.reduce(''){|m| break m if uri.index(m)==nil; m+='x'}
      uri = uri.gsub(embed, x)
      embed = x
    end
    uri = URI(uri).to_s
    @store.transaction do
      obid = ObID.new(@store[:idchars], @store[:idminlen], @store[:idseed])
      begin
        idval = @store[:idnext]
        @store[:idnext] += 1
        idstr = obid.str idval
      end until @wordishes.findin(idstr).empty? && !@store.root?(idstr)
      uri = uri.gsub(embed, idstr) if embed != nil
      @store[idstr] = uri
      idstr
    end
  end
  def get(idstr)
    idstr = idstr.to_s
    @mutex.synchronize{ @links[idstr] ||= @store.transaction(true){ @store[idstr] } }
  end
end
