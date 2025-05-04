# We can determine the initial coordinates of the stone using
# just three hailstones. Modelling the rock's trajectory as:
#
# x = x0 + vx t
# y = y0 + vy t
# z = z0 + vz t
#
# and each hailstone as:
#
# x[n] + vx[n] t
# y[n] + vy[n] t
# z[n] + vz[n] t
#
# we can say that:
#
# x0 + vx T1 = x1 + vx1 T1
# x0 + vx T2 = x2 + vx2 T2
# x0 + vx T3 = x3 + vx3 T3
#
# y0 + vy T1 = y1 + vy1 T1
# y0 + vy T2 = y2 + vy2 T2
# y0 + vy T3 = y3 + vy3 T3
#
# z0 + vz T1 = z1 + vz1 T1
# z0 + vz T2 = z2 + vz2 T2
# z0 + vz T3 = z3 + vz3 T3
#
# i.e. a system with 9 equations and 9 variables. If this system
# has a solution, it must be unique. And given the way the
# problem is presented, we can assume the solution exists.
#
# The problem can be reduced to a 3x3 system with only
# T1, T2, T3 as variables:
#
# (x1 + v1x T1 - x2 - vx2 T2) / (T1 - T2) = (x1 + v1x T1 - x3 - v3x T3) / (T1 - T3)
# (y1 + v1y T1 - y2 - vy2 T2) / (T1 - T2) = (y1 + v1y T1 - y3 - v3y T3) / (T1 - T3)
# (z1 + v1z T1 - z2 - vz2 T2) / (T1 - T2) = (z1 + v1z T1 - z3 - v3z T3) / (T1 - T3)
#
# This system is a pain to solve by hand so I'll just drop it
# in WolframAlpha: https://www.wolframalpha.com/input?i=system+equation+calculator

file = File.read "day24_input.txt"
hailstone_descriptors = file.split "\n"
hailstone_descriptors = hailstone_descriptors[0..2]

class Hailstone
  attr_accessor :px
  attr_accessor :py
  attr_accessor :pz
  attr_accessor :vx
  attr_accessor :vy
  attr_accessor :vz
  def initialize(descriptor)
    positions_and_velocities = descriptor.split "@"
    positions = positions_and_velocities[0].split(",")
    velocities = positions_and_velocities[1].split(",")
    self.px = positions[0].to_i
    self.py = positions[1].to_i
    self.pz = positions[2].to_i
    self.vx = velocities[0].to_i
    self.vy = velocities[1].to_i
    self.vz = velocities[2].to_i
  end
end

hailstones = hailstone_descriptors.map do |d|
  Hailstone.new d
end

# Inputs for WolframAlpha (where x = T1, y = T2, z = T3):
x1 = hailstones[0].px
v1x = hailstones[0].vx
x2 = hailstones[1].px
v2x = hailstones[1].vx
x3 = hailstones[2].px
v3x = hailstones[2].vx
first_input = "Divide[#{x1}+#{v1x}x-#{x2}-#{v2x}y,x-y]=Divide[#{x1}+#{v1x}x-#{x3}-#{v3x}z,x-z]"

y1 = hailstones[0].py
v1y = hailstones[0].vy
y2 = hailstones[1].py
v2y = hailstones[1].vy
y3 = hailstones[2].py
v3y = hailstones[2].vy
second_input = "Divide[#{y1}+#{v1y}x-#{y2}-#{v2y}y,x-y]=Divide[#{y1}+#{v1y}x-#{y3}-#{v3y}z,x-z]"

z1 = hailstones[0].pz
v1z = hailstones[0].vz
z2 = hailstones[1].pz
v2z = hailstones[1].vz
z3 = hailstones[2].pz
v3z = hailstones[2].vz
third_input = "Divide[#{z1}+#{v1z}x-#{z2}-#{v2z}y,x-y]=Divide[#{z1}+#{v1z}x-#{z3}-#{v3z}z,x-z]"

puts first_input
puts second_input
puts third_input

# We let the tool solve the system and input the results by console
puts "Write the results in order..."
t1 = gets.chomp.to_i
t2 = gets.chomp.to_i
_t3 = gets.chomp.to_i

# Finally, we replace in the previous expressions in order to get
# the vector's components and then the initial coordinates
vx = Rational(x1 + v1x * t1 - x2 - v2x * t2, t1 - t2)
vy = Rational(y1 + v1y * t1 - y2 - v2y * t2, t1 - t2)
vz = Rational(z1 + v1z * t1 - z2 - v2z * t2, t1 - t2)

x0 = x1 + v1x * t1 - vx * t1
y0 = y1 + v1y * t1 - vy * t1
z0 = z1 + v1z * t1 - vz * t1

result = x0 + y0 + z0
# If everything's alright, result should be an integer already,
# but it's still represented as a Rational
puts result.to_i
