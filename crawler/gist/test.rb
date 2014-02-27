module B
  attr_accessor :d
  def c
    x
  end
  def e
    puts d
  end
end
class A
  attr_accessor :q
  extend B
  def self.x
    puts "fkdfjlkdfjgkldfjglk"
  end
end

a=A.new
a.q=1
puts a.q