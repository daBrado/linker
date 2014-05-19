#
# Link Store
#
# Store mappings between Obfuscated IDs and URIs, and persist to a flat file.
#

require_relative 'obid'
require_relative 'wordishes'

require 'uri'

class LinkStore
  IDCHARS = [('a'..'z'),('A'..'Z'),('0'..'9')].map{|r|r.to_a}.reduce(:+)
  IDMINLEN = 4
  IDSEED = Random.new_seed
  WORDMINLEN = 3
  REUSABLE_FLAG = 'r'
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
    idchars = meta.shift.chars
    idminlen, idseed = meta.map{|v|Integer(v)}
    @obid = ObID.new(idchars, idminlen, idseed)
    links_list = @store.map{|l| id, uri, flags = l.chomp.split(' '); [id, uri, flags||'']}
    @idnext = links_list.empty? ? 0 : @obid.val(links_list.last[0])+1
    @links = links_list.map{|id,uri,_|[id,uri]}.to_h
    @reusable_uris = links_list.select{|_,_,flags|flags.include?(REUSABLE_FLAG)}.map{|id,uri,_|[uri,id]}.to_h
    @mutex = Mutex.new
  end
  def create(uri, reusable:true)
    uri = URI(uri).to_s
    @mutex.synchronize do
      idstr = reusable ? @reusable_uris[uri] : nil
      if !idstr
        begin
          idval = @idnext
          @idnext += 1
          idstr = @obid.str idval
        end until @wordishes.findin(idstr).empty? && !@links.key?(idstr)
        @links[idstr] = uri
        @reusable_uris[uri] = idstr if reusable
        @store.puts [idstr, uri, reusable ? REUSABLE_FLAG : nil].compact.join(' '); @store.fsync
      end
      idstr
    end
  end
  def get(idstr)
    @mutex.synchronize{ @links[idstr.to_s] }
  end
end
