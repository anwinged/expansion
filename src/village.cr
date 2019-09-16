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
  abstract def start(world : World)
  abstract def finish(world : World)
end

class BuildWoodMillCommand < Command
  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    printf "start build mill at [%d:%d]\n", @point.x, @point.y
    return 30
  end

  def finish(world : World)
    printf "finish build mill at [%d,%d]\n", @point.x, @point.y
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
      printf "start cut down wood at [%d,%d] -> %d -> %d -> [%d,%d]\n",
        @point.x, @point.y,
        dist, @wood,
        wood_point.x, wood_point.y
      return BASE_TIME + 2 * dist
    else
      printf "no wood tile\n"
      @wood = 0
      return BASE_TIME
    end
  end

  def finish(world : World)
    printf "finish cut down wood at [%d,%d]\n", @point.x, @point.y
    world.resources.add_wood(@wood)
    world.push(GetWoodCommand.new(@point))
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
    printf "world:plan `%s` at %d\n", typeof(command), done_at
    @queue.push(done_at, command)
  end

  def run(ts : Int32)
    loop do
      item = @queue.pop(ts)
      if item.nil?
        break
      end
      cmd_ts, cmd = item[:ts], item[:cmd]
      @ts = cmd_ts
      printf "world:finish `%s` at %d\n", typeof(cmd), cmd_ts
      cmd.finish(self)
    end
  end
end

w = World.new
w.map.print
w.push(BuildWoodMillCommand.new(Point.new(0, 0)))
w.run(120)
printf "Wood: %d\n", w.resources.wood
