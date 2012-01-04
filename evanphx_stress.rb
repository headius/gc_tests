require 'benchmark'

case RUBY_ENGINE
when "ruby"
  GC::Profiler.enable
end

class Simple
  attr_accessor :next
end

def current_mem
  `ps -o "%mem rss" -p #{$$}`.split("\n").last.split(/\s+/)[1..-1]
end

saves = 0

top = Simple.new

puts Benchmark.measure {
  outer = 10
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

case RUBY_ENGINE
when 'jruby'
  require 'java'
  java.lang.management.ManagementFactory.get_garbage_collector_mx_beans.each do |gc_bean|
    puts "GC name: #{gc_bean.name}"
    puts "Collection count: #{gc_bean.collection_count}"
    puts "Collection time: #{gc_bean.collection_time/1000.0}s"
  end
when 'ruby'
  puts "Collection count: #{GC.count}"
  puts "Collection time: #{GC::Profiler.total_time}s"
when 'rbx'
  require 'rubinius/agent'
  agent = Rubinius::Agent.loopback
  puts "Young GC count: #{agent.get('gc.young.count')}"
  puts "Young GC time: #{agent.get('gc.young.total_wallclock')}"
  puts "Mature GC count: #{agent.get('gc.full.count')}"
  puts "Mature GC time: #{agent.get('gc.full.total_wallclock')}"
end
