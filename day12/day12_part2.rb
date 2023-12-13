require 'benchmark'
require 'set'

def consumed_condition_numbers(prev, conditions, condition_numbers, consumed)
  if conditions.empty?
    return [consumed]
  end
  if conditions[0] == '#'
    if !(condition_numbers.empty?) && condition_numbers[0] > 0
      condition_numbers[0] = condition_numbers[0] - 1
      consumed = consumed + 1
    else
      return []
    end
  end
  if conditions[0] == '.' && !(condition_numbers.empty?) && prev == '#'
    if condition_numbers[0] == 0
      condition_numbers = condition_numbers[1..]
    else
      return []
    end
  end
  if conditions[0] == '?'
    conditions1 = conditions.clone
    conditions1[0] = '.'
    conditions2 = conditions.clone
    conditions2[0] = '#'
    return consumed_condition_numbers(prev, conditions1, condition_numbers.clone, consumed) + consumed_condition_numbers(prev, conditions2, condition_numbers.clone, consumed)
  end
  consumed_condition_numbers(conditions[0], conditions[1..], condition_numbers, consumed)
end

def subtract_consumptions(array, consumptions, prev)
  if consumptions > 1
    if array[0] > 1
      array[0] = array[0] - 1
    else
      array = array[1..]
    end
    subtract_consumptions(array, consumptions - 1, prev)
  elsif consumptions == 1
    if prev == '.' && array[0] == 1
      array = array[1..]
    else
      array[0] = array[0] - 1
    end
    array
  else
    array
  end
end

def make_map(conditions, condition_numbers, prev, last)
  map = {}
  map.default = 0
  (condition_numbers.sum * 5).times do |m|
    array = consumed_condition_numbers(prev, conditions + last, subtract_consumptions(Array.new(5).fill(condition_numbers).flatten, m, prev), 0)
    array.to_set.each do |n|
      map[[m, n]] = array.count(n)
    end
  end
  map
end

def calculate_arrangements(condition_numbers, iteration_number, prev, consumed)
  if iteration_number == 4
    if prev == '.'
      return $dot_final[[consumed, condition_numbers]]
    else
      return $hash_final[[consumed, condition_numbers]]
    end
  end
  sum = 0
  if prev == '.'
    $dot_dot.each do |consumptions, occurrences|
      if consumptions[0] == consumed
        new_conditions = condition_numbers - consumptions[1]#subtract_consumptions(condition_numbers, consumptions[1], '.')
        sum = sum + occurrences * calculate_arrangements(new_conditions, iteration_number + 1, '.', consumed + consumptions[1])
      end
    end
    $dot_hash.each do |consumptions, occurrences|
      if consumptions[0] == consumed
        new_conditions = condition_numbers - consumptions[1]#subtract_consumptions(condition_numbers, consumptions[1], '#')
        sum = sum + occurrences * calculate_arrangements(new_conditions, iteration_number + 1, '#', consumed + consumptions[1])
      end
    end
  else
    $hash_dot.each do |consumptions, occurrences|
      if consumptions[0] == consumed
        new_conditions = condition_numbers - consumptions[1]#subtract_consumptions(condition_numbers, consumptions[1], '.')
        sum = sum + occurrences * calculate_arrangements(new_conditions, iteration_number + 1, '.', consumed + consumptions[1])
      end
    end
    $hash_hash.each do |consumptions, occurrences|
      if consumptions[0] == consumed
        new_conditions = condition_numbers - consumptions[1]#subtract_consumptions(condition_numbers, consumptions[1], '#')
        sum = sum + occurrences * calculate_arrangements(new_conditions, iteration_number + 1, '#', consumed + consumptions[1])
      end
    end
  end
  sum
end

def arrangements_splitting(conditions, condition_numbers)
  $dot_final = make_map(conditions, condition_numbers, '.', '')
  $hash_final = make_map(conditions, condition_numbers, '#', '')
  $dot_dot = make_map(conditions, condition_numbers, '.', '.')
  $dot_hash = make_map(conditions, condition_numbers, '.', '#')
  $hash_dot = make_map(conditions, condition_numbers, '#', '.')
  $hash_hash = make_map(conditions, condition_numbers, '#', '#')
  calculate_arrangements(condition_numbers.sum * 5, 0, '.', 0)
end

t = Benchmark.realtime do
  lines = File.read("day12_input.txt").split("\n")
  total = lines.reduce 0 do |prev, line|
    conditions = line.split(" ")[0]
    condition_numbers = line.split(" ")[1].split(",").map &:to_i
    arr = arrangements_splitting(conditions, condition_numbers)
    prev + arr
  end
  puts total
end
puts t