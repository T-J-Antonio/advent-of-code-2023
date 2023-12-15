def string_hash(string)
  hash = 0
  string.each_char do |c|
    hash = ((hash + c.ord) * 17) % 256
  end
  hash
end

strings = File.read("day15_input.txt").split ","
boxes = Array.new(256).fill []
strings.each do |str|
  if str.end_with? "-"
    label = str.gsub "-", ""
    str_hash = string_hash(label)
    boxes[str_hash] = boxes[str_hash].filter do |lens| lens[0] != label end
  else
    label = str.split("=")[0]
    focal_length = str.split("=")[1].to_i
    str_hash = string_hash(label)
    index = boxes[str_hash].find_index do |lens| lens[0] == label end
    if index.nil?
      boxes[str_hash] = boxes[str_hash] + [[label, focal_length]]
    else
      boxes[str_hash][index] = [label, focal_length]
    end
  end
end
res = 0
boxes.each_with_index do |box, i|
  box.each_with_index do |lens, j|
    res = res + (i + 1) * (j + 1) * lens[1]
  end
end
puts res