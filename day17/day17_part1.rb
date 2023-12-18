require 'set'

$city_map = []
lines = File.read("day17_input.txt").split "\n"
$max_x = lines[0].length
$max_y = lines.length
lines.each_with_index do |line, i|
  line.chars.each_with_index do |c, j|
    $city_map[j + i * $max_x] = c.to_i
  end
end

class Path
  attr_accessor :last_three_steps
  attr_accessor :node
  attr_accessor :number
  def initialize(last_three_steps, node)
    @last_three_steps = last_three_steps
    @node = node
    @number = $city_map[node] - 1
  end

  def make_step
    if number > 0
      self.number = self.number - 1
      [self]
    else
      list_to_return = []
      if node % $max_x != 0 && last_three_steps != %w[left left left] && last_three_steps[2] != "right"
        list_to_return.push Path.new(
          [last_three_steps[1], last_three_steps[2], "left"],
          node - 1)
      end
      if node % $max_x != $max_x - 1 && last_three_steps != %w[right right right] && last_three_steps[2] != "left"
        list_to_return.push Path.new(
          [last_three_steps[1], last_three_steps[2], "right"],
          node + 1)
      end
      if node >= $max_x && last_three_steps != %w[up up up] && last_three_steps[2] != "down"
        list_to_return.push Path.new(
          [last_three_steps[1], last_three_steps[2], "up"],
          node - $max_x)
      end
      if node < $max_x * $max_y - $max_x && last_three_steps != %w[down down down] && last_three_steps[2] != "up"
        list_to_return.push Path.new(
          [last_three_steps[1], last_three_steps[2], "down"],
          node + $max_x)
      end
      list_to_return
    end
  end
end

$path_history = []

def filter_paths(paths)
  new_paths = []
  paths.each do |path|
    prev_paths = $path_history[path.node]
    if prev_paths.nil?
      new_paths.push path
      if path.number == 0
        $path_history[path.node] = [path.clone]
      end
    else
      unless prev_paths.any? do |path2|
        path.last_three_steps == path2.last_three_steps
      end
        new_paths.push path
        if path.number == 0
          $path_history[path.node] = $path_history[path.node] + [path.clone]
        end
      end
    end
  end
  new_paths
end

iterations = 0
start = Path.new %w[_ _ _], 0
start.number = 0
paths = [start]
until paths.any? { |path| path.node == $max_x * $max_y - 1 && path.number == 0 } do
  resulting_paths = []
  paths.each do |path|
    resulting_paths.push path.make_step
  end
  paths = resulting_paths.flatten
  iterations = iterations + 1
  paths = filter_paths(paths)
end
puts iterations