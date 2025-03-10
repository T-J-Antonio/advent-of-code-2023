require "set"

class Brick
  attr_accessor :start_x
  attr_accessor :end_x
  attr_accessor :start_y
  attr_accessor :end_y
  attr_accessor :start_z
  attr_accessor :end_z
  attr_accessor :supports
  attr_accessor :supporting
  attr_accessor :processed

  def initialize(description)
    start_and_end = description.split "~"
    starts = start_and_end[0].split ","
    self.start_x = starts[0].to_i
    self.start_y = starts[1].to_i
    self.start_z = starts[2].to_i
    ends = start_and_end[1].split ","
    self.end_x = ends[0].to_i
    self.end_y = ends[1].to_i
    self.end_z = ends[2].to_i
    self.processed = false
  end

  def is_directly_above?(brick)
    self.start_z > brick.end_z and intersects_x_and_y brick
  end

  def intersects_x_and_y(brick)
    not (
      self.end_x < brick.start_x or brick.end_x < self.start_x or self.end_y < brick.start_y or brick.end_y < self.start_y
    )
  end

  def own_height
    end_z - start_z + 1
  end

  def cumulative_height
    if supports.size > 0
      supports[0].cumulative_height + own_height
    else
      own_height
    end
  end

  def process_supports(all_bricks)
    if self.processed
      return
    end

    bricks_directly_below = all_bricks.filter do |b2| is_directly_above? b2 end

    if bricks_directly_below.size > 0
      bricks_directly_below.each do |b2| b2.process_supports all_bricks end
      max_cumulative_height = bricks_directly_below.max_by do |b2| b2.cumulative_height end.cumulative_height
      self.supports = bricks_directly_below.filter do |b2| b2.cumulative_height == max_cumulative_height end
    else
      self.supports = []
    end

    self.processed = true
  end

  def transitive_supporting
    [self] + supporting + supporting.flat_map do |b| b.transitive_supporting end
  end

  def chain_reaction
    detonator_supporting = transitive_supporting.to_set.to_a

    completely_filtered = false
    until completely_filtered
      completely_filtered = detonator_supporting.all? do |b| b == self || (b.supports - detonator_supporting).size == 0 end
      detonator_supporting = detonator_supporting.filter do |b| b == self || (b.supports - detonator_supporting).size == 0 end
    end

    detonator_supporting - [self]
  end
end

lines = File.read("day22_input.txt").split "\n"
bricks = lines.map do |l| Brick.new l end

bricks.each do |b|
  b.process_supports bricks
end

bricks.each do |b|
  b.supporting = bricks.filter do |b2| b2.supports.include? b end
end

chain_reaction_total = 0
bricks.each do |b|
  chain_reaction = b.chain_reaction.to_set
  chain_reaction_total = chain_reaction_total + chain_reaction.size
end

puts chain_reaction_total
