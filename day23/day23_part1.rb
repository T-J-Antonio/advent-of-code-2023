file = File.read "day23_input.txt"
@map = file.split "\n"
@map = @map.map do |r| r.chars end

@height = @map.size
@width = @map[0].size

@start_position = [0, @map[0].index(".")]
@end_position = [@height - 1, @map[-1].index(".")]

def possible_next_positions(current_position)
  current_position_terrain = @map[current_position[0]][current_position[1]]
  case current_position_terrain
  when ">"
    return [[current_position[0], current_position[1] + 1]]
  when "<"
    return [[current_position[0], current_position[1] - 1]]
  when "v"
    return [[current_position[0] + 1, current_position[1]]]
  when "^"
    return [[current_position[0] - 1, current_position[1]]]
  else # "."
    adjacent_positions = []
    adjacent_positions.push [current_position[0] - 1, current_position[1]] unless current_position[0] == 0
    adjacent_positions.push [current_position[0] + 1, current_position[1]] unless current_position[0] == @height - 1
    adjacent_positions.push [current_position[0], current_position[1] - 1] unless current_position[1] == 0
    adjacent_positions.push [current_position[0], current_position[1] + 1] unless current_position[1] == @width - 1

    return adjacent_positions.filter do |p|
      @map[p[0]][p[1]] != "#"
    end
  end
end

trails = [[@start_position]] # Array<Array<[Integer, Integer]>>
complete_trails = []

while trails.size > 0
  trails = trails.flat_map do |t|
    pnp = possible_next_positions t[-1]
    pnp = pnp - t
    non_complete_trails = []
    pnp.each do |p|
      if p == @end_position
        complete_trails.push t
      else
        non_complete_trails.push(t + [p])
      end
    end
    non_complete_trails
  end
end

longest_trail = complete_trails.max_by do |t| t.size end
puts longest_trail.size
