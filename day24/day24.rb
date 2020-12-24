require 'set'

class HexagonalFloor

  attr_reader :tiles

  DIR = {
    "ne" => [1,0,-1],
    "e"  => [1,-1,0],
    "se" => [0,-1,1],
    "sw" => [-1,0,1],
    "w"  => [-1,1,0],
    "nw" => [0,1,-1]
  }.freeze

  def initialize
    @tiles = Set.new
    @neighbors_cache = Hash.new { |hash, key| hash[key] = neighbors(key)}
  end

  def add_tile(directions)
    tile = directions.map{|d| DIR[d]}.transpose.map(&:sum)
    is_black?(tile) ? @tiles.delete(tile) : @tiles.add(tile)
  end

  def is_black?(tile)
    @tiles.include?(tile)
  end

  def is_white?(tile)
    !is_black?(tile)
  end

  def black_neighbors_of(tile)
    @neighbors_cache[tile].clone.keep_if{ |neighbor| is_black?(neighbor)}
  end

  def neighbors(tile)
    DIR.values.map{ |d| d.zip(tile).map(&:sum) }
  end

  def flip_all
    to_white,to_black = Set.new,Set.new
    tiles_to_consider = @tiles.clone
    tiles_to_consider.merge(@tiles.map{|t| @neighbors_cache[t] }.flatten(1))

    tiles_to_consider.each do |tile|
      num_bn = black_neighbors_of(tile).length
      if is_white?(tile) && num_bn == 2
        to_black.add(tile)
      elsif is_black?(tile) && !num_bn.between?(1,2)
        to_white.add(tile)
      end
    end
    @tiles.subtract(to_white)
    @tiles.merge(to_black) unless to_black.empty?
  end

end


floor = HexagonalFloor.new
File.read('input_lg.txt').split("\n").each do |line|
  floor.add_tile(line.scan(/e|w|se|sw|nw|ne/))
end

# Part 1
puts "There are #{floor.tiles.size} black floor tiles"

# Part 2
100.times do |day|
  floor.flip_all
  puts "Day #{day+1}: #{floor.tiles.size}"
end

puts "Part 2: #{floor.tiles.size}"
