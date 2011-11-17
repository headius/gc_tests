# stress GC by creating lots of young and old objects

loop do
  old_ary = []
  10000.times do
    old_ary << 'foo'
    new_ary = []
    100000.times do
      new_ary << 'bar'
    end
  end
  puts "looped"
end
