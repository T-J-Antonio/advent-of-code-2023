require "set"
content = File.read "day21_input.txt"
lines = content.split "\n"
@matrix = lines.map do |l| l.chars end
start_y = @matrix.find_index do |l| l.include? "S" end
start_x = @matrix[start_y].find_index "S"

def next_positions(position)
  possible_positions = [
    [position[0] - 1, position[1]],
    [position[0] + 1, position[1]],
    [position[0], position[1] - 1],
    [position[0], position[1] + 1]
  ]
  possible_positions.filter do |p|
    p[0].between?(0, 130) && p[1].between?(0, 130) &&
      (@matrix[p[1]][p[0]] == "." || @matrix[p[1]][p[0]] == "S")
  end
end

# first, we need to know how many dots we can reach in an "even iteration" or an "odd iteration" layout
positions = Set.new.add [start_x, start_y]
positions_passed = Set.new.add [start_x, start_y]
final_odd_positions = Set.new.add [start_x, start_y]
final_even_positions = Set.new
number_of_steps = 0
until positions.empty? do
  all_next_positions = positions.flat_map do |p| next_positions(p) end

  positions = all_next_positions.reject do |p|
    positions_passed.include? p
  end.to_set

  if number_of_steps.even?
    final_even_positions.merge positions
  else
    final_odd_positions.merge positions
  end

  positions_passed.merge all_next_positions

  number_of_steps = number_of_steps + 1
end

positions_in_even_iteration = final_even_positions.size # 7553
positions_in_odd_iteration = final_odd_positions.size # 7541

# 26501365 // 131 = 202300
# 26501365 % 131 = 65
# sum of even numbers 1..202299 = 202298 * 202300 / 4 = 10231221350
# sum of odd numbers 1..202299 = 202300 * 202300 / 4 = 10231322500
# positions in even iteration = 7553
# positions in odd iteration = 7541
# 1st = 7553
# all iterations except 1st and last 2 = 7553 * 4 * 10231221350 + 7541 * 4 * 10231322500 = 617723271316200
# last 2 = calculated manually

i = 202300
result = 7553 + 617723271316200

def no_of_positions_from(start, remaining_steps, iteration_number)
  positions = Set.new.add start
  positions_passed = Set.new.add start
  final_positions = Set.new
  final_positions.add start if iteration_number.odd?
  remaining_steps.times do |step_i|
    all_next_positions = positions.flat_map do |p| next_positions(p) end

    positions = all_next_positions.reject do |p|
      positions_passed.include? p
    end.to_set

    if (step_i + iteration_number).even?
      final_positions.merge positions
    end

    positions_passed.merge all_next_positions
  end

  final_positions.size
end

remaining_steps_corner_1 = 195
remaining_steps_edge = 130
remaining_steps_corner_2 = 64

corner_starts = [[0, 0], [0, 130], [130, 0], [130, 130]]
edge_starts = [[0, 65], [65, 0], [130, 65], [65, 130]]

result = result + (i - 1) * corner_starts.sum do |s|
  no_of_positions_from(s, remaining_steps_corner_1, 0)
end
result = result + edge_starts.sum do |s|
  no_of_positions_from(s, remaining_steps_edge, 1)
end
i = i + 1

result = result + (i - 1) * corner_starts.sum do |s|
  no_of_positions_from(s, remaining_steps_corner_2, 1)
end

puts result
