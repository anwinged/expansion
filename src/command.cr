require "colorize"

abstract class Command
  abstract def start(world : World) : Int32
  abstract def finish(world : World)
end

class BuildWoodMillCommand < Command
  BASE_TIME = 30

  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    printf "  << start build mill at [%d:%d]\n", @point.x, @point.y
    BASE_TIME
  end

  def finish(world : World)
    printf "  << finish build mill at [%d,%d]\n", @point.x, @point.y
    mill = WoodMillTile.new(@point)
    world.map.set(mill)
    world.push(GetWoodCommand.new(@point))
  end
end

class GetWoodCommand < Command
  BASE_TIME = 10
  BASE_WOOD = 80
  REST_TIME =  5

  def initialize(@point : Point)
    @wood = 0
  end

  def start(world : World) : Int32
    wood_tile = nearest_wood(world)
    stock_tile = nearest_stock(world)
    if wood_tile && stock_tile
      calc_time(wood_tile.as(Tile), stock_tile.as(Tile))
    else
      puts "  << no wood or stock tile".colorize(:red)
      REST_TIME
    end
  end

  private def calc_time(wood_tile : Tile, stock_tile : Tile)
    wood_dist = @point.distance(wood_tile.point)
    stock_dist = @point.distance(stock_tile.point)
    @wood = wood_tile.withdraw(BASE_WOOD)
    printf "  << wood %d, %d, %d\n", BASE_TIME, 2 * wood_dist, 2 * stock_dist
    BASE_TIME + 2 * wood_dist + 2 * stock_dist
  end

  def finish(world : World)
    printf "  << finish cut down wood at [%d,%d]\n", @point.x, @point.y
    world.resources.add_wood(@wood)
    world.push(GetWoodCommand.new(@point))
  end

  private def nearest_wood(world : World)
    world.map.nearest_tile @point do |tile|
      tile.supports(TileType::Wood) && tile.cur > 0
    end
  end

  private def nearest_stock(world : World)
    world.map.nearest_tile @point do |tile|
      tile.supports(TileType::Stock)
    end
  end
end

class BuildForesterHouseCommand < Command
  BASE_TIME = 50

  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    printf "  >> start build forester house at [%d:%d]\n", @point.x, @point.y
    BASE_TIME
  end

  def finish(world : World)
    printf "  >> finish build forester house at [%d,%d]\n", @point.x, @point.y
    tile = ForesterHouseTile.new(@point)
    world.map.set(tile)
    world.push(GrowWoodCommand.new(@point))
  end
end

class GrowWoodCommand < Command
  BASE_TIME = 15
  BASE_WOOD = 30
  REST_TIME =  5

  @wood_tile : Tile | Nil

  def initialize(@point : Point)
    @wood_tile = nil
  end

  def start(world : World) : Int32
    @wood_tile = nearest_wood(world)
    if @wood_tile
      calc_time(@wood_tile.as(Tile))
    else
      printf "  >> no wood tile\n"
      REST_TIME
    end
  end

  private def calc_time(wood_tile : Tile)
    wood_point = wood_tile.point
    dist = @point.distance(wood_point)
    printf "  >> start grow wood at [%d,%d] -> %d -> [%d,%d]\n",
      @point.x, @point.y,
      dist,
      wood_point.x, wood_point.y
    BASE_TIME + 2 * dist
  end

  def finish(world : World)
    printf "  >> finish grow wood at [%d,%d]\n", @point.x, @point.y
    if @wood_tile
      printf "  >> finish grow wood for %d\n", BASE_WOOD
      @wood_tile.as(Tile).charge(BASE_WOOD)
    end
    world.push(GrowWoodCommand.new(@point))
  end

  private def nearest_wood(world : World)
    world.map.nearest_tile @point do |tile|
      tile.supports(TileType::Wood) && tile.cur < tile.cap
    end
  end
end
