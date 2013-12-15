#
# Obfuscated Identifier
#
# One-to-one mapping between any positive integer and a weird-looking string.
#

class ObID
  def initialize(chars, minlen, seed)
    @chars = chars.sort.uniq.shuffle(random:Random.new(seed))
    @minlen = minlen
    @seed = seed
  end
  def reseed(seed, values, rng=Random.new(@seed))
    seed * (values.reduce([0,1]){|m,r|[m[0]+r*m[1],m[1]*@chars.size]}.reduce(:+) + rng.rand(seed))
  end
  def shuffle(array, undo:false)
    rng = Random.new(@seed+array.map{|c|@chars.index(c)}.reduce(:+))
    targets = array.map{rng.rand(array.size)}
    indicies = array.size.times.to_a
    indicies.reverse! if undo
    indicies.each{|i| tmp=array[i]; array[i]=array[targets[i]]; array[targets[i]]=tmp}
    array
  end
  def str(v)
    return nil if !(v>=0 && v.respond_to?(:divmod))
    rng = Random.new @seed
    fn = lambda{|v,seed,result|
      return result if (v == 0 && result.size >= @minlen)
      chars = @chars.shuffle random:Random.new(seed)
      q,r = v.divmod chars.size
      result += [[r,chars[r]]]
      seed = reseed(seed, result.map{|r,c|r}, rng)
      fn.call(q, seed, result)
    }
    shuffle(fn.call(v, @seed, []).map{|r,c|c}).join
  end
  def val(s)
    rng = Random.new @seed
    fn = lambda{|s,seed,result|
      return result if s.size == result.size
      chars = @chars.shuffle random:Random.new(seed)
      r = chars.index s[result.size]
      result += [r]
      seed = reseed(seed, result, rng)
      fn.call(s, seed, result)
    }
    v = fn.call(shuffle(s.chars, undo:true).join, @seed, []) rescue nil
    return nil if v == nil || v.size < @minlen || v.drop(@minlen).last == 0
    v.zip(0..Float::INFINITY).map{|v,i|v*@chars.size**i}.reduce(:+)
  end
end
