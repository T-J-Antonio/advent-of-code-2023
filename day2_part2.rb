lines = File.read("day2_input.txt").split "\n"
res = lines.reduce 0 do |prev_sum, line|
  game_and_revelations = line.split ":"
  revelations = game_and_revelations[1].split ";"
  min_values = revelations.reduce [0,0,0] do |prev, revelation|
    colours = revelation.split ","
    red = 0
    blue = 0
    green = 0
    colours.each do |colour|
      if colour.end_with? "red" then red = colour.gsub("red", "").to_i end
      if colour.end_with? "blue" then blue = colour.gsub("blue", "").to_i end
      if colour.end_with? "green" then green = colour.gsub("green", "").to_i end
    end
    [
      prev[0] > red ? prev[0] : red,
      prev[1] > blue ? prev[1] : blue,
      prev[2] > green ? prev[2] : green
    ]
  end
  power = min_values.reduce 1, :*
  prev_sum + power
end
puts res