#
# Wordishes
#
# Find all the word-like things in a string.
#

require 'set'

class Wordishes
  def initialize(words=[], minlen=3)
    @words = Set.new(words.map{|word| word.strip.downcase}.select{|word| word.size >= minlen})
    @minlen = minlen
  end
  def findin(str)
    str = str.downcase.tr('234567890','zeasgtbgo')
    ['l','i'].flat_map{|c| str.tr('1',c)}.uniq.flat_map{|s|
      (@minlen..s.size).flat_map{|len|
        (0..s.size-len).map{|start| s[start,len]}
      }
    }.uniq.select{|w| @words.include? w}
  end
end
