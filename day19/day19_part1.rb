content = File.read "day19_input.txt"
content = content.split "\n\n"
workflows_str = content[0].split "\n"
parts_str = content[1].split "\n"

@workflows_map = {}
workflows_str.each do |line|
  name_and_instructions = line.split "{"
  name = name_and_instructions[0]
  instructions = name_and_instructions[1].chop
  instruction_list = instructions.split ","
  last_instruction = instruction_list.pop
  blocks = instruction_list.map do |i|
    condition_and_action = i.split ":"
    condition = condition_and_action[0]
    category = condition[0].to_sym
    number = condition[2..].to_i
    operation = condition[1] == ">" ? Proc.new do |n| n > number end : Proc.new do |n| n < number end
    action = condition_and_action[1]
    Proc.new do |part|
      value = part[category]
      if operation.call value
        action
      else
        nil
      end
    end
  end
  workflow = Proc.new do |part|
    result = nil
    blocks.each do |block|
      if result.nil?
        result = block.call part
      end
    end
    if result.nil?
      result = last_instruction
    end
    result
  end
  @workflows_map[name] = workflow
end

parts = parts_str.map do |str|
  values = str.gsub("{x=", " ").gsub(",m=", " ").gsub(",a=", " ").gsub(",s=", " ").gsub("}", "").split " "
  values = values.map do |s| s.to_i end
  { x: values[0], m: values[1], a: values[2], s: values[3] }
end

def run_through_workflows(workflow, part)
  res = @workflows_map[workflow].call part
  if res == "A"
    true
  elsif res == "R"
    false
  else
    run_through_workflows res, part
  end
end

sum = 0
parts.map do |part|
  is_ok = run_through_workflows "in", part
  sum = sum + part.values.sum if is_ok
end
puts sum