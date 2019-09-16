struct Point
  def initialize(@x : Int32, @y : Int32)
  end

  def x
    @x
  end

  def y
    @y
  end

  def distance(p : Point) : Int32
    return (p.x - @x).abs + (p.y - @y).abs
  end
end

abstract class Tile
  def initialize(@point : Point)
    @cap = 0
    @cur = 0
  end

  def point
    @point
  end

  def cur
    @cur
  end

  def withdraw(value)
    if value >= @cur
      wd = @cur
      @cur = 0
      return wd
    else
      @cur -= value
      return value
    end
  end

  def charge(value)
    if value + @cur > @cap
      @cur = @cap
    else
      @cur += value
    end
  end

  abstract def letter : Char
end

class GrassTile < Tile
  def letter : Char
    '.'
  end
end

class WoodTile < Tile
  def initialize(@point : Point, cap : Int32)
    @cap = cap
    @cur = cap
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

class Map
  def initialize
    @data = {} of String => Tile
    (0...4).each do |x|
      (0...4).each do |y|
        self.set(GrassTile.new(Point.new(x, y)))
      end
    end
    self.set(WoodTile.new(Point.new(1, 1), 100))
    self.set(WoodTile.new(Point.new(3, 1), 200))
    self.set(WoodTile.new(Point.new(2, 2), 100))
  end

  def get(point : Point) : Tile
    @data[key(point)]
  end

  def set(tile : Tile)
    @data[key(tile.point)] = tile
  end

  def set(point : Point, tile : Tile)
    @data[key(point)] = tile
  end

  def nearest_wood(point : Point) : Point | Nil
    p = nil
    d = 99999
    (0...4).each do |x|
      (0...4).each do |y|
        tile = self.get(Point.new(x, y))
        if tile.letter == 'f' && tile.cur > 0
          td = Point.new(x, y).distance(point)
          if td < d
            d = td
            p = Point.new(x, y)
          end
        end
      end
    end
    p
  end

  def nearest_any_wood(point : Point) : Point | Nil
    p = nil
    d = 99999
    (0...4).each do |x|
      (0...4).each do |y|
        tile = self.get(Point.new(x, y))
        if tile.letter == 'f'
          td = Point.new(x, y).distance(point)
          if td < d
            d = td
            p = Point.new(x, y)
          end
        end
      end
    end
    p
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
