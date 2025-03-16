file = File.read "day24_input.txt"
hailstone_descriptors = file.split "\n"

class Hailstone
  attr_accessor :px
  attr_accessor :py
  attr_accessor :vx
  attr_accessor :vy
  def initialize(descriptor)
    positions_and_velocities = descriptor.split "@"
    positions = positions_and_velocities[0].split(",")
    velocities = positions_and_velocities[1].split(",")
    self.px = positions[0].to_f
    self.py = positions[1].to_f
    self.vx = velocities[0].to_f
    self.vy = velocities[1].to_f
  end

  def slope # aka "m"
    vy / vx
  end

  def intercept # aka "b"
    py - slope * px
  end

  def paths_intersection(other_hailstone)
    return nil if self.slope == other_hailstone.slope # this means they're parallel

    x_intersection = - (self.intercept - other_hailstone.intercept) / (self.slope - other_hailstone.slope)
    y_intersection = self.slope * x_intersection + self.intercept

    [x_intersection, y_intersection]
  end

  def is_position_future?(position)
    vx > 0 ? position[0] > px : position[0] < px
  end
end

hailstones = hailstone_descriptors.map do |d|
  Hailstone.new d
end

future_intersections = 0

hailstones.each_with_index do |h, i|
  hailstones[i+1..].each_with_index do |h2, j|
    intersection = h.paths_intersection h2
    if not intersection.nil? and
      h.is_position_future? intersection and
      h2.is_position_future? intersection and
      intersection[0].between? 200000000000000, 400000000000000 and
      intersection[1].between? 200000000000000, 400000000000000
      future_intersections = future_intersections + 1
    end
  end
end

puts future_intersections
