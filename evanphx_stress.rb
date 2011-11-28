require 'benchmark'


class Simple
  attr_accessor :next
end

def current_mem
  `ps -o "%mem rss" -p #{$$}`.split("\n").last.split(/\s+/)[1..-1]
end

saves = 0

top = Simple.new

puts Benchmark.measure {
  outer = 100
  total = 100000
  per = 100

  outer.times do
    start = current_mem

    total.times do
      per.times { Simple.new }
      s = Simple.new
      top.next = s
      top = s
      saves += 1
    end

    fin = current_mem

    p start
    p fin
  end
}

p :saves => saves


found = 0

x = top
while x
  found += 1
  x = x.next
end

p found
