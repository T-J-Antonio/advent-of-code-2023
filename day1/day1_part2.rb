number_words = {
  "one" => "1",
  "two" => "2",
  "three" => "3",
  "four" => "4",
  "five" => "5",
  "six" => "6",
  "seven" => "7",
  "eight" => "8",
  "nine" => "9"
}

lines = File.read("day1_input.txt").split
res = 0
lines.each do |line|
  numbers = line
              .gsub(/one|two|three|four|five|six|seven|eight|nine/, number_words)
              .gsub /[a-z]|[A-Z]/, ""
  reversed_numbers = line.reverse
                         .gsub(/eno|owt|eerht|ruof|evif|xis|neves|thgie|enin/) do |s| number_words[s.reverse] end
                         .gsub /[a-z]|[A-Z]/, ""
  res += numbers[0].to_i * 10 + reversed_numbers[0].to_i
end
puts res