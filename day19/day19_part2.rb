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

$acceptable_conditions = []

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
    self.transitions.push [final_new, action] unless action == "R"
  end
  def apply(previous_conditions)
    self.transitions.each do |t|
      new_conditions = combine_conditions t[0], previous_conditions
      if t[1] == "A"
        $acceptable_conditions.push new_conditions
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

puts $acceptable_conditions