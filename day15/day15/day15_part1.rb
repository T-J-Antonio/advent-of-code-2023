def string_hash(string)
  hash = 0
  string.each_char do |c|
    hash = ((hash + c.ord) * 17) % 256
  end
  hash
end

strings = File.read("day15_input.txt").split ","
res = strings.reduce 0 do |prev, str|
  prev + string_hash(str)
end
puts res