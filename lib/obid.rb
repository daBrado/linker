#
# Obfuscated Identifier
#
# One-to-one mapping between any positive integer and a weird-looking string.
#

class ObID
  def initialize(chars, minlen, seed)
    @chars = chars.sort.uniq
    @minlen = minlen
    @seed = seed
  end
  def str(v)
    return nil if v<0 || !v.respond_to?(:times)
    fn = lambda{|v,rng,result|
      return result if (v == 0 && result.size >= @minlen)
      chars = @chars.shuffle random:rng
      q,r = v.divmod chars.size
      (result += [[r,chars[r]]]).map{|r,c|r}.reduce(:+).times.each{rng.rand}
      fn.call(q, rng, result)
    }
    fn.call(v,Random.new(@seed),[]).map{|r,c|c}.join
  end
  def val(s)
    fn = lambda{|s,rng,result|
      return result if s.size == result.size
      chars = @chars.shuffle random:rng
      r = chars.index s[result.size]
      (result += [r]).reduce(:+).times.each{rng.rand}
      fn.call(s, rng, result)
    }
    v = fn.call(s,Random.new(@seed),[]) rescue nil
    return nil if v == nil || v.size < @minlen || v.drop(@minlen).last == 0
    v.zip(0..Float::INFINITY).map{|v,i|v*@chars.size**i}.reduce(:+)
  end
end
