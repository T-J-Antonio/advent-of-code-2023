require 'set'

FIVE_OF_A_KIND = 7
FOUR_OF_A_KIND = 6
FULL_HOUSE = 5
THREE_OF_A_KIND = 4
TWO_PAIR = 3
ONE_PAIR = 2
HIGH_CARD = 1

def type(hand)
  array = hand.chars
  set = array.to_set
  if set.size == 1
    return FIVE_OF_A_KIND
  end
  if set.size == 4
    return ONE_PAIR
  end
  if set.size == 5
    return HIGH_CARD
  end
  if array.count(array[0]) == 4 || array.count(array[1]) == 4
    return FOUR_OF_A_KIND
  end
  if set.size == 2
    return FULL_HOUSE
  end
  if array.count(array[0]) == 3 || array.count(array[1]) == 3 || array.count(array[2]) == 3
    return THREE_OF_A_KIND
  end
  TWO_PAIR
end

CARD_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9,
                "T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14 }

def first_difference(hand1, hand2)
  hand2 = hand2.chars
  hand1.chars.each_with_index do |c, i|
    return CARD_VALUES[c] - CARD_VALUES[hand2[i]] unless CARD_VALUES[c] == CARD_VALUES[hand2[i]]
  end
  0
end

lines = File.read("day7_input.txt").split "\n"
lines = lines.sort do |line1, line2|
  hand1 = line1.split(" ")[0]
  hand2 = line2.split(" ")[0]
  if type(hand1) != type(hand2)
    type(hand1) - type(hand2)
  else
    first_difference(hand1, hand2)
  end
end
total = 0
lines.each_with_index do |line, i|
  total = total + line.split(" ")[1].to_i * (i + 1)
end
puts total