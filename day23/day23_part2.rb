file = File.read "day23_input.txt"
@map = file.split "\n"
@map = @map.map do |r| r.chars end

@height = @map.size
@width = @map[0].size

def adjacent_positions(position)
  adjacent_positions = []
  adjacent_positions.push [position[0] - 1, position[1]] unless position[0] == 0
  adjacent_positions.push [position[0] + 1, position[1]] unless position[0] == @height - 1
  adjacent_positions.push [position[0], position[1] - 1] unless position[1] == 0
  adjacent_positions.push [position[0], position[1] + 1] unless position[1] == @width - 1

  adjacent_positions.filter do |p|
    @map[p[0]][p[1]] != "#"
  end
end

nodes = []
@map.each_with_index do |row, i|
  row.each_with_index do |terrain, j|
    nodes.push [i, j] if terrain != "#" and adjacent_positions([i, j]).size != 2
  end
end

def trail_to_node(p, trail)
  next_p = adjacent_positions(p) - trail
  if next_p.size != 1 # we've reached a node, and it's p
    trail + [p]
  else # we're still "inside" the edge
    trail_to_node(next_p[0], trail + [p])
  end
end

@edges = [] # [node_1, node_2, weight] (node_1, node_2 are unordered, this graph is undirected)
nodes.each_with_index do |n, node_1_id|
  start_positions_for_trails = adjacent_positions(n)
  trails_to_nodes = start_positions_for_trails.map do |p|
    trail_to_node(p, [n])
  end
  trails_to_nodes.each do |t|
    node_2_id = nodes.find_index t[-1]
    # this ensures each edge is inserted once instead of twice
    unless @edges.any? do |e| e[0] == node_2_id and e[1] == node_1_id end
      @edges.push [node_1_id, node_2_id, t.size - 1]
    end
  end
end

@start_node = 0
@end_node = nodes.size - 1

def paths(current_node, accum_path, accum_weight)
  if current_node == @end_node
    return [[accum_path + [current_node], accum_weight]]
  end
  all_connected_edges = @edges.filter do |e|
    e[0] == current_node or e[1] == current_node
  end
  next_edges = all_connected_edges.reject do |e|
    accum_path.include? e[0] or accum_path.include? e[1]
  end
  next_edges.flat_map do |e|
    next_node = e[0] == current_node ? e[1] : e[0]
    paths(next_node, accum_path + [current_node], accum_weight + e[2])
  end
end

all_paths = paths(0, [], 0)
best_path = all_paths.max_by do |p| p[1] end
puts best_path[1]
