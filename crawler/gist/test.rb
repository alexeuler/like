module B
  def c
    puts b
  end
end
class A
  extend B
  attr_accessor :b
  def a
    lambda {puts b}
  end
  def self.b
    puts "Yp"
  end
end

A.c