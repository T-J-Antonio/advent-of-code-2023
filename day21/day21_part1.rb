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
    @matrix[p[1]][p[0]] == "."
  end
end

positions = Set.new.add [start_x, start_y]
positions_passed = Set.new.add [start_x, start_y]
final_positions = Set.new.add [start_x, start_y]
64.times do |n|
  # what are all the next positions reached?
  all_next_positions = positions.flat_map do |p| next_positions(p) end

  # out of them, which ones had we not reached before?
  positions = all_next_positions.reject do |p|
    positions_passed.include? p
  end.to_set

  # are these final positions? (because N = 64, this means "is n odd?")
  if n.odd?
    final_positions.merge positions
  end

  # in the end, all of these have been passed
  positions_passed.merge all_next_positions
end

result = final_positions.size
puts result
