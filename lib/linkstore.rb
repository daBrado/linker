#
# Link Store
#
# Use a PStore to create and find mappings between Obfuscated IDs and URIs.
#

require_relative './obid'
require_relative './wordishes'

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
      @obid = ObID.new(@store[:idchars], @store[:idminlen], @store[:idseed])
    end
  end
  def create(uri)
    uri = URI uri
    @store.transaction do
      begin
        idval = @store[:idnext]
        @store[:idnext] += 1
        idstr = @obid.str idval
      end while !@wordishes.findin(idstr).empty?
      @store[idval] = uri.to_s
      idstr
    end
  end
  def get(idstr)
    @store.transaction(true){ @store[@obid.val idstr.to_s] }
  end
end