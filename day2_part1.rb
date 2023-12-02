lines = File.read("day2_input.txt").split "\n"
res = 0
lines.each do |line|
  game_and_revelations = line.split ":"
  revelations = game_and_revelations[1].split ";"
  if revelations.all? do |revelation|
    colours = revelation.split ","
    colours.all? do |colour|
      (colour.end_with? "red" and colour.gsub("red", "").to_i <= 12) or
        (colour.end_with? "blue" and colour.gsub("blue", "").to_i <= 14) or
        (colour.end_with? "green" and colour.gsub("green", "").to_i <= 13)
      end
    end
    res += game_and_revelations[0].gsub("Game ", "").to_i
  end
end
puts res