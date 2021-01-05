require 'set'

class Tile

  attr_reader :id, :data_cache

  NUM_EDGES = 4
  SIDES = {:N=>0,:E=>1,:S=>2,:W=>3}
  EDGE_LABELS =  %i(a b c d e f g h)
  EDGE_STATES = [%i(a b c d e d g b),
                 %i(h a f c d c b a),
                 %i(g h e f c f a h),
                 %i(b g d e f e h g)]

  def initialize(args)
    @id = args[:id]
    @data = args[:data].freeze
    @edge_hash = EDGE_LABELS.zip(all_edges).to_h
    @flipped,@num_rotations = false,0
    @data_cache = {[@flipped,@num_rotations] => @data.dup }
  end

  # returns Set of all possible edge orientations
  def all_edges
    @all_edges ||= begin
      edges = [ @data.first,@data.map{ |r| r[-1]  }.join,
                @data.last, @data.map{ |r| r[0] }.join]
      Set.new(edges+edges.map{|e|e.reverse})
    end
  end

  # rotate edges 90 degrees clockwise
  def rotate!
    @num_rotations = (@num_rotations+1) % NUM_EDGES
  end

  # flip edges on the Y axis
  def flip!
    @flipped = !@flipped
  end

  # returns the edge at the specified direction (N S E W)
  def edge_at(dir)
    flip_offset = @flipped ? SIDES[dir] + NUM_EDGES : SIDES[dir]
    @edge_hash[EDGE_STATES[@num_rotations][flip_offset]]
  end

  # returns true of self is a neighbor of tile, false otherwise
  def neighbor_of?(tile)
    self != tile && !shared_edges(tile).empty?
  end

  # returns shared edges between two tiles
  def shared_edges(tile)
    all_edges & tile.all_edges
  end

  # returns true if this tile has the given edge
  def has_edge?(edge)
    return all_edges.include?(edge)
  end

  # orient self with edge[direction] == edge
  def arrange!(dir,edge)
    return false unless has_edge?(edge)
    8.times do |i|
      return true if edge_at(dir) == edge
      i == NUM_EDGES-1 ? flip! : rotate!
    end
  end

  # return a copy of tile data with borders removed
  def remove_borders
    d = data
    # remove the first and last rows
    d.shift ; d.pop
    # remove the first and last characters of each row
    d.each{|row| row.slice!(0); row.slice!(-1) }
  end

  # return frequency of char in tile data
  def count(char)
    @count ||= @data.map{|row| row.count(char) }.reduce(:+)
  end

  def data
    @data_cache[[@flipped,@num_rotations]] ||= begin
      d = @data.dup.map{ |a| a.split("") }
      @num_rotations.times { d = d.transpose.map(&:reverse) }
      d.map{|d1| d1.reverse! } if @flipped
      d.map{|d1| d1.join}
    end
  end

  def to_s
    data.join("\n")
  end
end
