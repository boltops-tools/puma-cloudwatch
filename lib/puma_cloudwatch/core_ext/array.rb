class Array
  # Note: Array#sum only available in ruby 2.4+
  # Thanks: http://www.viarails.net/q/How-to-sum-an-array-of-numbers-in-Ruby
  def sum
    inject(0) {|sum, i|  sum + i }
  end
end
