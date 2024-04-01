content = File.read "sarasa.txt"
content = content.split "\n\n"
workflows_str = content[0].split "\n"

def max(n1, n2)
  n1 > n2 ? n1 : n2
end
def min(n1, n2)
  n1 < n2 ? n1 : n2
end

$base_conditions = {
  "x<" => 4001,
  "x>" => 0,
  "m<" => 4001,
  "m>" => 0,
  "a<" => 4001,
  "a>" => 0,
  "s<" => 4001,
  "s>" => 0
}
def new_b_c
  $base_conditions.clone
end

$conditions = []

def invert(category_and_operation, number)
  category = category_and_operation[0]
  operation = category_and_operation[1]
  if operation == "<"
    [category + ">", number - 1]
  else
    [category + "<", number + 1]
  end
end

def combine_conditions(c1, c2)
  {
    "x<" => min(c1["x<"], c2["x<"]),
    "x>" => max(c1["x>"], c2["x>"]),
    "m<" => min(c1["m<"], c2["m<"]),
    "m>" => max(c1["m>"], c2["m>"]),
    "a<" => min(c1["a<"], c2["a<"]),
    "a>" => max(c1["a>"], c2["a>"]),
    "s<" => min(c1["s<"], c2["s<"]),
    "s>" => max(c1["s>"], c2["s>"])
  }
end

$workflows_map = {}

class Workflow
  attr_accessor :c_o_and_ns
  attr_accessor :transitions
  def initialize
    self.c_o_and_ns = []
    self.transitions = []
  end
  def add_transition(category_and_operation, number, action)
    all_the_previous_ones_negated = c_o_and_ns.inject(new_b_c) do |accum, t|
      new_c_o_and_n = invert(t[0], t[1])
      new_conditions = new_b_c
      new_conditions[new_c_o_and_n[0]] = new_c_o_and_n[1]
      combine_conditions(accum, new_conditions)
    end
    new_conditions = new_b_c
    new_conditions[category_and_operation] = number
    self.c_o_and_ns.push [category_and_operation, number]
    final_new = combine_conditions(all_the_previous_ones_negated, new_conditions)
    self.transitions.push [final_new, action]
  end
  def apply(previous_conditions)
    self.transitions.each do |t|
      new_conditions = combine_conditions t[0], previous_conditions
      if t[1] == "A"
        $conditions.push [:a, new_conditions]
      elsif t[1] == "R"
        $conditions.push [:r, new_conditions]
      else
        $workflows_map[t[1]].apply new_conditions
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

$workflows_map["in"].apply new_b_c

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

def process_conditions(index, xs, ms, as, ss)
  return 0 if index >= $conditions.size or xs.empty? or ms.empty? or as.empty? or ss.empty?
  conditions = $conditions[index][1]
  accept = $conditions[index][0] == :a
  complying_xs = xs.intersect(ValueRange.new [conditions["x>"], conditions["x<"]])
  complying_ms = ms.intersect(ValueRange.new [conditions["m>"] ,conditions["m<"]])
  complying_as = as.intersect(ValueRange.new [conditions["a>"], conditions["a<"]])
  complying_ss = ss.intersect(ValueRange.new [conditions["s>"] ,conditions["s<"]])
  borders = []
  if conditions["x>"] > 1
    borders.push 0, conditions["x>"] + 1
  end
  if conditions["x<"] < 4000
    borders.push conditions["x<"] - 1, 4001
  end
  noncomplying_xs = xs.intersect(ValueRange.new borders)
  borders = []
  if conditions["m>"] > 1
    borders.push 0, conditions["m>"] + 1
  end
  if conditions["m<"] < 4000
    borders.push conditions["m<"] - 1, 4001
  end
  noncomplying_ms = ms.intersect(ValueRange.new borders)
  borders = []
  if conditions["a>"] > 1
    borders.push 0, conditions["a>"] + 1
  end
  if conditions["a<"] < 4000
    borders.push conditions["a<"] - 1, 4001
  end
  noncomplying_as = as.intersect(ValueRange.new borders)
  borders = []
  if conditions["s>"] > 1
    borders.push 0, conditions["s>"] + 1
  end
  if conditions["s<"] < 4000
    borders.push conditions["s<"] - 1, 4001
  end
  noncomplying_ss = ss.intersect(ValueRange.new borders)
  branch1 = process_conditions(index + 1, complying_xs, complying_ms, complying_as, noncomplying_ss)
  branch2 = process_conditions(index + 1, complying_xs, complying_ms, noncomplying_as, complying_ss)
  branch3 = process_conditions(index + 1, complying_xs, complying_ms, noncomplying_as, noncomplying_ss)
  branch4 = process_conditions(index + 1, complying_xs, noncomplying_ms, complying_as, complying_ss)
  branch5 = process_conditions(index + 1, complying_xs, noncomplying_ms, complying_as, noncomplying_ss)
  branch6 = process_conditions(index + 1, complying_xs, noncomplying_ms, noncomplying_as, complying_ss)
  branch7 = process_conditions(index + 1, complying_xs, noncomplying_ms, noncomplying_as, noncomplying_ss)
  branch8 = process_conditions(index + 1, noncomplying_xs, complying_ms, complying_as, complying_ss)
  branch9 = process_conditions(index + 1, noncomplying_xs, complying_ms, complying_as, noncomplying_ss)
  branch10 = process_conditions(index + 1, noncomplying_xs, complying_ms, noncomplying_as, complying_ss)
  branch11 = process_conditions(index + 1, noncomplying_xs, complying_ms, noncomplying_as, noncomplying_ss)
  branch12 = process_conditions(index + 1, noncomplying_xs, noncomplying_ms, complying_as, complying_ss)
  branch13 = process_conditions(index + 1, noncomplying_xs, noncomplying_ms, complying_as, noncomplying_ss)
  branch14 = process_conditions(index + 1, noncomplying_xs, noncomplying_ms, noncomplying_as, complying_ss)
  branch15 = process_conditions(index + 1, noncomplying_xs, noncomplying_ms, noncomplying_as, noncomplying_ss)
  if accept
    these_acceptables = complying_xs.size * complying_ms.size * complying_as.size * complying_ss.size
  else
    these_acceptables = 0
  end
  these_acceptables + branch1 + branch2 + branch3 + branch4 + branch5 + branch6 + branch7 + branch8 + branch9 + branch10 + branch11 + branch12 + branch13 + branch14 + branch15
end

result = process_conditions(0, ValueRange.new([0, 4001]), ValueRange.new([0, 4001]), ValueRange.new([0, 4001]), ValueRange.new([0, 4001]))
puts result
