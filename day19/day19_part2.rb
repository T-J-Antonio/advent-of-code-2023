content = File.read "day19_input.txt"
content = content.split "\n\n"
workflows_str = content[0].split "\n"

class ValueRange
  attr_accessor :borders
  def initialize(borders)
    actual_borders = []
    prev = nil
    borders.each do |b|
      if b - 1 == prev
        actual_borders.pop
      else
        actual_borders.push b
      end
      prev = b
    end
    self.borders = actual_borders
  end
  def intersect(other)
    these_borders = self.borders
    other_borders = other.borders
    these_are_open = false
    other_are_open = false
    i = 0
    j = 0
    result = []
    until these_borders.size == i or other_borders.size == j
      v1 = these_borders[i]
      v2 = other_borders[j]
      if v1 <= v2
        these_are_open = true if i.even?
        unless these_are_open ^ other_are_open
          result.push v1
        end
        these_are_open = false unless i.even?
        i = i + 1
      else
        other_are_open = true if j.even?
        unless these_are_open ^ other_are_open
          result.push v2
        end
        other_are_open = false unless j.even?
        j = j + 1
      end
    end
    ValueRange.new result
  end
  def empty?
    self.borders.empty?
  end
  def size
    res = 0
    self.borders.each_with_index do |value, i|
      res = res + (i.even? ? - value : value - 1)
    end
    res
  end
end

$workflows_map = {}
$result = 0

class Workflow
  attr_accessor :transitions
  def initialize
    self.transitions = []
  end
  def add_transition(category_and_operation, number, action)
    self.transitions.push [category_and_operation, number, action]
  end
  def apply(xs, ms, as, ss)
    return if xs.empty? or ms.empty? or as.empty? or ss.empty?
    transitions.each do |t|
      category_and_operation = t[0]
      number = t[1]
      action = t[2]
      new_xs = xs
      new_ms = ms
      new_as = as
      new_ss = ss
      case category_and_operation
      when "x<"
        new_xs = xs.intersect ValueRange.new [0, number]
        xs = xs.intersect ValueRange.new [number - 1, 4001]
      when "x>"
        new_xs = xs.intersect ValueRange.new [number, 4001]
        xs = xs.intersect ValueRange.new [0, number + 1]
      when "m<"
        new_ms = ms.intersect ValueRange.new [0, number]
        ms = ms.intersect ValueRange.new [number - 1, 4001]
      when "m>"
        new_ms = ms.intersect ValueRange.new [number, 4001]
        ms = ms.intersect ValueRange.new [0, number + 1]
      when "a<"
        new_as = as.intersect ValueRange.new [0, number]
        as = as.intersect ValueRange.new [number - 1, 4001]
      when "a>"
        new_as = as.intersect ValueRange.new [number, 4001]
        as = as.intersect ValueRange.new [0, number + 1]
      when "s<"
        new_ss = ss.intersect ValueRange.new [0, number]
        ss = ss.intersect ValueRange.new [number - 1, 4001]
      else
        new_ss = ss.intersect ValueRange.new [number, 4001]
        ss = ss.intersect ValueRange.new [0, number + 1]
      end
      if action == "A"
        $result = $result + new_xs.size * new_ms.size * new_as.size * new_ss.size
      elsif action != "R" # if action is R, we shouldn't do anything with these numbers
        $workflows_map[action].apply new_xs, new_ms, new_as, new_ss
      end
    end
  end
end

workflows_str.each do |line|
  workflow = Workflow.new
  name_and_instructions = line.split "{"
  name = name_and_instructions[0]
  instructions = name_and_instructions[1].chop
  instruction_list = instructions.split ","
  last_instruction = instruction_list.pop
  instruction_list.each do |i|
    condition_and_action = i.split ":"
    condition = condition_and_action[0]
    category_and_operation = condition[0..1]
    number = condition[2..].to_i
    action = condition_and_action[1]
    workflow.add_transition category_and_operation, number, action
  end
  workflow.add_transition "x>", 0, last_instruction
  $workflows_map[name] = workflow
end

$workflows_map["in"].apply(
  ValueRange.new([0, 4001]),
  ValueRange.new([0, 4001]),
  ValueRange.new([0, 4001]),
  ValueRange.new([0, 4001])
)

puts $result
