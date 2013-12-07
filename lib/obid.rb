#
# Obfuscated Identifier
#
# One-to-one mapping between any positive integer and a weird-looking string.
#

class ObID
  OFFSET = lambda{|o,r|(o+r+1)*2}
  def initialize(chars, minlen, seed)
    @chars = chars.sort.uniq.shuffle(random:Random.new(seed))
    @minlen = minlen
  end
  def str(v)
    return nil if v<0
    fn = lambda{|v,offset,result|
      return result if (v == 0 && result.size >= @minlen)
      q,r = v.divmod @chars.size
      fn.call(q, OFFSET[offset,r], result+[@chars[(r+offset)%@chars.size]])
    }
    fn.call(v,0,[]).join
  end
  def val(s)
    fn = lambda{|s,offset,result|
      return result if s.empty?
      r = (@chars.index(s[0])-offset)%@chars.size
      fn.call(s[1..-1], OFFSET[offset,r], result+[r])
    }
    v = fn.call(s,0,[]) rescue nil
    return nil if v == nil || v.size < @minlen || v.drop(@minlen).last == 0
    v.zip(0..Float::INFINITY).map{|v,i|v*@chars.size**i}.reduce(:+)
  end
end
