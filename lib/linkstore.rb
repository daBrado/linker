#
# Link Store
#
# Use a PStore to create and find mappings between Obfuscated IDs and URIs.
#

require_relative 'obid'
require_relative 'wordishes'

require 'uri'

class LinkStore
  IDCHARS = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|r|r.to_a}.reduce(:+)
  IDMINLEN = 4
  IDSEED = Random.new_seed
  WORDMINLEN = 3
  def initialize(file, words: [])
    @wordishes = Wordishes.new(words, WORDMINLEN)
    (@store = File.new file, 'a+').rewind
    @store.sync = true
    meta = @store.gets
    if !meta
      @store.puts [IDCHARS.join, IDMINLEN, IDSEED].join(' '); @store.fsync
      @store.rewind
      meta = @store.gets
    end
    meta = meta.split
    @idchars = meta.shift.chars
    @idminlen, @idseed = meta.map{|v|Integer(v)}
    @links = @store.map{|l|l.chomp.split(' ',2)}.to_h
    @idnext = @links.count # This is an underestimate, but on the first new link we'll scan for the correct next ID
    @mutex = Mutex.new
  end
  def create(uri, embed:nil)
    if embed != nil
      x = loop.reduce(''){|m| break m if uri.index(m)==nil; m+='x'}
      uri = uri.gsub(embed, x)
      embed = x
    end
    uri = URI(uri).to_s
    @mutex.synchronize do
      obid = ObID.new(@idchars, @idminlen, @idseed)
      begin
        idval = @idnext
        @idnext += 1
        idstr = obid.str idval
      end until @wordishes.findin(idstr).empty? && !@links.key?(idstr)
      uri = uri.gsub(embed, idstr) if embed != nil
      @links[idstr] = uri
      @store.puts [idstr, uri].join(' '); @store.fsync
      idstr
    end
  end
  def get(idstr)
    @mutex.synchronize{ @links[idstr.to_s] }
  end
end
