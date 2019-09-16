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
    return BASE_TIME
  end

  def finish(world : World)
    printf "  << finish build mill at [%d,%d]\n", @point.x, @point.y
    mill = WoodMillTile.new(@point)
    world.map.set(mill)
    world.push(GetWoodCommand.new(@point))
  end
end

class GetWoodCommand < Command
  BASE_TIME =  5
  BASE_WOOD = 80

  def initialize(@point : Point)
    @wood = 0
  end

  def start(world : World) : Int32
    wood_tile = nearest_wood(world)
    if !wood_tile.nil?
      calc_time(wood_tile.as(Tile))
    else
      printf "  << no wood tile\n"
      @wood = 0
      return BASE_TIME
    end
  end

  private def calc_time(wood_tile : Tile)
    wood_point = wood_tile.point
    dist = @point.distance(wood_point)
    @wood = wood_tile.withdraw(BASE_WOOD)
    printf "  << start cut down wood at [%d,%d] -> %d -> %d -> [%d,%d]\n",
      @point.x, @point.y,
      dist, @wood,
      wood_point.x, wood_point.y
    return BASE_TIME + 2 * dist
  end

  def finish(world : World)
    printf "  << finish cut down wood at [%d,%d]\n", @point.x, @point.y
    world.resources.add_wood(@wood)
    world.push(GetWoodCommand.new(@point))
  end

  private def nearest_wood(world : World)
    world.map.nearest_tile @point do |tile|
      tile.letter == 'f' && tile.cur > 0
    end
  end
end

class BuildForesterHouseCommand < Command
  BASE_TIME = 50

  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    printf "  >> start build forester house at [%d:%d]\n", @point.x, @point.y
    return BASE_TIME
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

  @wood_tile : Tile | Nil

  def initialize(@point : Point)
    @wood_tile = nil
  end

  def start(world : World) : Int32
    @wood_tile = nearest_wood(world)
    if !@wood_tile.nil?
      calc_time(@wood_tile.as(Tile))
    else
      printf "no wood tile\n"
      @wood = 0
      return BASE_TIME
    end
  end

  private def calc_time(wood_tile : Tile)
    wood_point = wood_tile.point
    dist = @point.distance(wood_point)
    printf "  >> start grow wood at [%d,%d] -> %d -> [%d,%d]\n",
      @point.x, @point.y,
      dist,
      wood_point.x, wood_point.y
    return BASE_TIME + 2 * dist
  end

  def finish(world : World)
    printf "  >> finish grow wood at [%d,%d]\n", @point.x, @point.y
    if !@wood_tile.nil?
      @wood_tile.as(Tile).charge(BASE_WOOD)
    end
    world.push(GrowWoodCommand.new(@point))
  end

  private def nearest_wood(world : World)
    world.map.nearest_tile @point do |tile|
      tile.letter == 'f' && tile.cur < tile.cur
    end
  end
end
