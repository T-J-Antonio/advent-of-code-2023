lines = File.read("day4_input.txt").split "\n"
res = lines.reduce 0 do |prev, line|
  info = line.split(":")[1]
  fields = info.split "|"
  winning_numbers = fields[0].split(" ").map do |str| str.to_i end
  actual_numbers = fields[1].split(" ").map do |str| str.to_i end
  matches = winning_numbers.filter do |n| actual_numbers.include? n end.length
  prev + (matches > 0 ? 2 ** (matches - 1) : 0)
end
puts res