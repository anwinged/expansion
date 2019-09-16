require "colorize"
require "./queue"
require "./map"

class Resources
  def initialize
    @wood = 0
  end

  def add_wood(x)
    @wood += x
  end

  def wood
    @wood
  end
end

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
    wood_point = world.map.nearest_wood(@point)
    if !wood_point.nil?
      dist = @point.distance(wood_point)
      tile = world.map.get(wood_point)
      @wood = tile.withdraw(BASE_WOOD)
      printf "  << start cut down wood at [%d,%d] -> %d -> %d -> [%d,%d]\n",
        @point.x, @point.y,
        dist, @wood,
        wood_point.x, wood_point.y
      return BASE_TIME + 2 * dist
    else
      printf "  << no wood tile\n"
      @wood = 0
      return BASE_TIME
    end
  end

  def finish(world : World)
    printf "  << finish cut down wood at [%d,%d]\n", @point.x, @point.y
    world.resources.add_wood(@wood)
    world.push(GetWoodCommand.new(@point))
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

  @wood_point : Point | Nil

  def initialize(@point : Point)
    @wood_point = nil
  end

  def start(world : World) : Int32
    wood_point = world.map.nearest_any_wood(@point)
    if !wood_point.nil?
      dist = @point.distance(wood_point)
      @wood_point = wood_point
      printf "  >> start grow wood at [%d,%d] -> %d -> [%d,%d]\n",
        @point.x, @point.y,
        dist,
        wood_point.x, wood_point.y
      return BASE_TIME + 2 * dist
    else
      printf "no wood tile\n"
      @wood = 0
      return BASE_TIME
    end
  end

  def finish(world : World)
    printf "  >> finish grow wood at [%d,%d]\n", @point.x, @point.y
    if !@wood_point.nil?
      tile = world.map.get(@wood_point.as(Point))
      tile.charge(BASE_WOOD)
    end
    world.push(GrowWoodCommand.new(@point))
  end
end

class World
  def initialize
    @ts = 0
    @resources = Resources.new
    @map = Map.new
    @queue = App::CommandQueue.new
  end

  private def ts
    @ts
  end

  def resources
    @resources
  end

  def map
    @map
  end

  def push(command : Command)
    dur = command.start(self)
    done_at = @ts + dur
    printf "world : %d : plan `%s` at %d\n", @ts, typeof(command), done_at
    @queue.push(done_at, command)
  end

  def run(ts : Int32)
    loop do
      item = @queue.pop(ts)
      if item.nil?
        break
      end
      command_ts, command = item[:ts], item[:cmd]
      @ts = command_ts
      command.finish(self)
      printf "world : %d : finish `%s`\n", @ts, typeof(command)
    end
  end
end

w = World.new
w.map.print
w.push(BuildWoodMillCommand.new(Point.new(0, 0)))
w.push(BuildForesterHouseCommand.new(Point.new(0, 0)))
w.run(60)
printf "Wood: %d\n", w.resources.wood
