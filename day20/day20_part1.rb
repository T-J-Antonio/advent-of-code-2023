$comm_module_db = Hash.new
$high_counter = 0
$low_counter = 0

class CommModule
  attr_accessor :inputs
  attr_accessor :outputs
  attr_accessor :id
  def initialize(id, outputs)
    @id = id
    @inputs = []
    @outputs = outputs
  end
  def add_input(input)
    inputs.push input
  end
end

class FlipFlop < CommModule
  attr_accessor :on
  attr_accessor :do_next_output
  def initialize(id, outputs)
    @on = false
    super id, outputs
  end
  def high(input)
    []
  end
  def low(input)
    self.on = !on
    outputs.map do |o|
      [id, o, on ? :high : :low]
    end
  end
end

class Conjunction < CommModule
  attr_accessor :input_memories
  def initialize_input_memories
    self.input_memories = inputs.to_h do |input| [input, :low] end
  end
  def high(input)
    input_memories[input] = :high
    all_high = input_memories.values.all? do |v| v == :high end
    outputs.map do |o|
      [id, o, all_high ? :low : :high]
    end
  end
  def low(input)
    input_memories[input] = :low
    all_high = input_memories.values.all? do |v| v == :high end
    outputs.map do |o|
      [id, o, all_high ? :low : :high]
    end
  end
end

class Broadcaster < CommModule
  def low(input)
    outputs.map do |o|
      [id, o, :low]
    end
  end
end

content = File.read 'day20_input.txt'
lines = content.split "\n"
lines.each do |line|
  id_and_outputs = line.split ' -> '
  id = id_and_outputs[0]
  outputs = id_and_outputs[1].split(', ').map do |s| s.to_sym end
  if id[0] == '%'
    id = id[1..].to_sym
    new_comm_module = FlipFlop.new id, outputs
  elsif id[0] == '&'
    id = id[1..].to_sym
    new_comm_module = Conjunction.new id, outputs
  else
    id = :broadcaster
    new_comm_module = Broadcaster.new id, outputs
  end
  $comm_module_db[id] = new_comm_module
end

$comm_module_db.each do |id, comm_module|
  comm_module.outputs.each do |output|
    $comm_module_db[output]&.add_input id
  end
end

$comm_module_db.values.each do |comm_module|
  comm_module.initialize_input_memories if comm_module.is_a? Conjunction
end

1000.times do
  $pulses = [[:button, :broadcaster, :low]]
  until $pulses.empty?
    new_pulses = $pulses.flat_map do |p|
      sender = p[0]
      receiver = $comm_module_db[p[1]]
      type = p[2]
      $high_counter += 1 if type == :high
      $low_counter += 1 if type == :low
      receiver&.send type, sender
    end
    $pulses = new_pulses.reject do |p| p.nil? end
  end
end

result = $high_counter * $low_counter
puts result
