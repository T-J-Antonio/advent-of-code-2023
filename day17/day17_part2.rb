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
  attr_accessor :last_ten_steps
  attr_accessor :node
  attr_accessor :number
  def initialize(last_ten_steps, node)
    @last_ten_steps = last_ten_steps
    @node = node
    @number = $city_map[node] - 1
  end

  def make_step
    if number > 0
      self.number = self.number - 1
      [self]
    elsif last_ten_steps[6..].to_set.length > 1
      if last_ten_steps[9] == "left" && node % $max_x != 0
        return [Path.new(last_ten_steps[1..] + ["left"], node - 1)]
      elsif last_ten_steps[9] == "right" && node % $max_x != $max_x - 1
        return [Path.new(last_ten_steps[1..] + ["right"], node + 1)]
      elsif last_ten_steps[9] == "up" && node >= $max_x
        return [Path.new(last_ten_steps[1..] + ["up"], node - $max_x)]
      elsif last_ten_steps[9] == "down" && node < $max_x * $max_y - $max_x
        return [Path.new(last_ten_steps[1..] + ["down"], node + $max_x)]
      else
        return []
      end
    else
      list_to_return = []
      if node % $max_x != 0 && last_ten_steps[9] != "right" && last_ten_steps != %w[left left left left left left left left left left]
        list_to_return.push Path.new(
          last_ten_steps[1..] + ["left"],
          node - 1)
      end
      if node % $max_x != $max_x - 1 && last_ten_steps[9] != "left" && last_ten_steps != %w[right right right right right right right right right right]
        list_to_return.push Path.new(
          last_ten_steps[1..] + ["right"],
          node + 1)
      end
      if node >= $max_x && last_ten_steps[9] != "down" && last_ten_steps != %w[up up up up up up up up up up]
        list_to_return.push Path.new(
          last_ten_steps[1..] + ["up"],
          node - $max_x)
      end
      if node < $max_x * $max_y - $max_x && last_ten_steps[9] != "up" && last_ten_steps != %w[down down down down down down down down down down]
        list_to_return.push Path.new(
          last_ten_steps[1..] + ["down"],
          node + $max_x)
      end
      list_to_return
    end
  end
end

def suffix_with(array, elem)
  if array[-1] != elem
    0
  else
    1 + suffix_with(array[..-2], elem)
  end
end

def suffix(array)
  elem = array[-1]
  1 + suffix_with(array[..-2], elem)
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
        path.last_ten_steps[9] == path2.last_ten_steps[9] &&
          suffix(path.last_ten_steps) == suffix(path2.last_ten_steps)
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
start = Path.new %w[_ _ _ _ _ _ _ _ _ _], 0
start.number = 0
paths = [start]

until paths.any? { |path| path.node == $max_x * $max_y - 1 && path.number == 0 && path.last_ten_steps[6..].to_set.length == 1 } do
  resulting_paths = []
  paths.each do |path|
    resulting_paths.push path.make_step
  end
  paths = resulting_paths.flatten
  iterations = iterations + 1
  paths = filter_paths(paths)
end
puts iterations