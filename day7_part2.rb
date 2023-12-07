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
  cards_to_occurrences = {}
  array.each do |c|
    unless c == "J"
      cards_to_occurrences[c] = 0 if cards_to_occurrences[c].nil?
      cards_to_occurrences[c] = cards_to_occurrences[c] + 1
    end
  end
  js = array.count "J"
  # edge case: JJJJJ (doesn't fill any entries in the map)
  return FIVE_OF_A_KIND if js == 5
  cards_to_occurrences = cards_to_occurrences.map do |entry|
    [entry[0], entry[1] + js]
  end
  max_occurrences = cards_to_occurrences.max_by do |entry| entry[1] end
  if max_occurrences[1] == 5
    return FIVE_OF_A_KIND
  end
  if max_occurrences[1] == 4
    return FOUR_OF_A_KIND
  end
  if max_occurrences[1] == 3
    new_cards_to_occurrences = cards_to_occurrences.reject do |entry| entry == max_occurrences end
    if new_cards_to_occurrences.max_by do |entry| entry[1] - js end[1] - js == 2
      return FULL_HOUSE
    else
      return THREE_OF_A_KIND
    end
  end
  if max_occurrences[1] == 2
    new_cards_to_occurrences = cards_to_occurrences.reject do |entry| entry == max_occurrences end
    if new_cards_to_occurrences.max_by do |entry| entry[1] - js end[1] - js == 2
      return TWO_PAIR
    else
      return ONE_PAIR
    end
  end
  HIGH_CARD
end

CARD_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9,
                "T" => 10, "J" => 1, "Q" => 12, "K" => 13, "A" => 14 }

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
  hand = line.split(" ")[0]
  total = total + line.split(" ")[1].to_i * (i + 1)
end
puts total