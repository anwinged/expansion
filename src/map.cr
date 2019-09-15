abstract class Tile
  abstract def letter : Char
end

class GrassTile < Tile
  def letter : Char
    '.'
  end
end

class WoodTile < Tile
  def initialize(cap : Int32)
    @cap = cap
    @cur = cap
  end

  def cap
    @cap
  end

  def inc(v : Int32)
    @cur += v
    if @cur < 0
      @cur = 0
    end
    if @cur > @cap
      @cur = @cap
    end
  end

  def letter : Char
    'f'
  end
end

class WoodMillTile < Tile
  def letter : Char
    'm'
  end
end

class ForesterHouseTile < Tile
  def letter : Char
    'h'
  end
end

struct Point
  def initialize(@x : Int32, @y : Int32)
  end

  def x
    @x
  end

  def y
    @y
  end
end

class Map
  def initialize
    @data = {} of String => Tile
    (0...4).each do |x|
      (0...4).each do |y|
        @data[key(Point.new(x, y))] = GrassTile.new
      end
    end
    @data[key(Point.new(1, 1))] = WoodTile.new(100)
    @data[key(Point.new(3, 1))] = WoodTile.new(200)
    @data[key(Point.new(2, 2))] = WoodTile.new(100)
  end

  def get(point : Point) : Tile
    @data[key(Point.new(x, y))]
  end

  def set(point : Point, tile : Tile)
    @data[key(point)] = tile
  end

  def print
    (0...4).each do |x|
      (0...4).each do |y|
        printf "%c", @data[key(Point.new(x, y))].letter
      end
      printf "\n"
    end
  end

  private def key(p : Point) : String
    return sprintf "%d:%d", p.x, p.y
  end
end
