def arrangements(prev, conditions, condition_numbers)
  if conditions.empty?
    return condition_numbers.empty? || condition_numbers == [0] ? 1 : 0
  end
  if conditions[0] == '#'
    if !(condition_numbers.empty?) && condition_numbers[0] > 0
      condition_numbers[0] = condition_numbers[0] - 1
    else
      return 0
    end
  end
  if conditions[0] == '.' && !(condition_numbers.empty?) && prev == '#'
    if condition_numbers[0] == 0
      condition_numbers = condition_numbers[1..]
    else
      return 0
    end
  end
  if conditions[0] == '?'
    conditions1 = conditions.clone
    conditions1[0] = '.'
    conditions2 = conditions.clone
    conditions2[0] = '#'
    return arrangements(prev, conditions1, condition_numbers.clone) + arrangements(prev, conditions2, condition_numbers.clone)
  end
  arrangements(conditions[0], conditions[1..], condition_numbers)
end

lines = File.read("day12_input.txt").split "\n"
total = lines.reduce 0 do |prev, line|
  conditions = line.split(" ")[0]
  condition_numbers = line.split(" ")[1].split(",").map &:to_i
  arr = arrangements('_', conditions, condition_numbers)
  prev + arr
end
puts total