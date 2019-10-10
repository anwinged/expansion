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
    alias TileRow = Array(Tile)
    alias DataArray = Array(TileRow)

    property data : DataArray

    def initialize(@rows : Int32, @cols : Int32)
      @data = DataArray.new @rows
      @rows.times do |row_index|
        tile_row = TileRow.new @cols
        @cols.times do |col_index|
          tile_row << PlateauTile.new(Point.new(row_index, col_index))
        end
        @data << tile_row
      end
      self.set(MainBaseTile.new(Point.new(0, 0)))
      self.set(CrystalTile.new(Point.new(1, 2), 100))
      self.set(CrystalTile.new(Point.new(4, 2), 200))
      self.set(CrystalTile.new(Point.new(3, 3), 100))
    end

    getter rows
    getter cols

    def get(point : Point) : Tile
      @data[point.x][point.y]
    end

    def get(x : Int32, y : Int32) : Tile
      get Point.new(x, y)
    end

    def set(tile : Tile)
      set tile.point, tile
    end

    def set(point : Point, tile : Tile)
      @data[point.x][point.y] = tile
    end

    def tiles(&block : Point, Tile -> _)
      (0...@rows).each do |x|
        (0...@cols).each do |y|
          point = Point.new(x, y)
          tile = self.get(point)
          yield point, tile
        end
      end
    end

    def nearest_tile(point : Point, &block : Tile -> Bool) : Tile | Nil
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
  end

  class MapGenerator
  end
end
