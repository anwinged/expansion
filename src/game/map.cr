module Game
  struct Point
    property x : Int32
    property y : Int32

    def initialize(@x : Int32, @y : Int32)
    end

    getter x
    getter y

    def distance(other) : Int32
      return (other.x - @x).abs + (other.y - @y).abs
    end
  end

  class Map
    SIZE = 4

    def initialize
      @data = {} of String => Tile
      (0...SIZE).each do |x|
        (0...SIZE).each do |y|
          self.set(PlateauTile.new(Point.new(x, y)))
        end
      end
      self.set(MainBaseTile.new(Point.new(0, 0)))
      self.set(CrystalTile.new(Point.new(1, 1), 100))
      self.set(CrystalTile.new(Point.new(3, 1), 200))
      self.set(CrystalTile.new(Point.new(2, 2), 100))
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

    def tiles
      (0...SIZE).each do |x|
        (0...SIZE).each do |y|
          point = Point.new(x, y)
          tile = self.get(point)
          yield point, tile
        end
      end
    end

    def nearest_tile(point : Point, &block) : Tile | Nil
      seek_tile = nil
      min_dist = Int32::MAX
      tiles do |tile_point, tile|
        if (yield tile)
          tile_dist = tile_point.distance(point)
          if tile_dist < min_dist
            min_dist = tile_dist
            seek_tile = tile
          end
        end
      end
      seek_tile
    end

    def print
      (0...SIZE).each do |x|
        (0...SIZE).each do |y|
          printf "%c", @data[key(Point.new(x, y))].letter
        end
        printf "\n"
      end
    end

    private def key(p : Point) : String
      return sprintf "%d:%d", p.x, p.y
    end
  end
end
