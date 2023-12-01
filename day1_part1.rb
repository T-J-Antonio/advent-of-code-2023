lines = File.read("day1_input.txt").split
res = 0
lines.each do |line|
  numbers = line.gsub /[a-z]|[A-Z]/, ""
  res += numbers[0].to_i * 10 + numbers[-1].to_i
end
puts res