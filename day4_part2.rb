lines = File.read("day4_input.txt").split "\n"
total_cards_list = []
matches_list = lines.map do |line|
  total_cards_list.push 1
  info = line.split(":")[1]
  fields = info.split "|"
  winning_numbers = fields[0].split(" ").map do |str| str.to_i end
  actual_numbers = fields[1].split(" ").map do |str| str.to_i end
  winning_numbers.filter do |n| actual_numbers.include? n end.length
end
matches_list.each_with_index do |matches, index|
  matches.times do |n|
    unless total_cards_list[index + n + 1].nil?
      total_cards_list[index + n + 1] = total_cards_list[index + n + 1] + total_cards_list[index]
    end
  end
end

puts total_cards_list.sum