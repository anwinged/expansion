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
    printf "start build mill at [%d, (%d:%d)]\n", world.ts, @point.x, @point.y
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
  BASE_WOOD = 20

  def initialize(@point : Point)
    @wood = 0
  end

  def start(world : World)
    wood_point = world.map.nearest_wood(@point)
    # if !wood_point.nil?
    #   printf "cut down wood at [%d,%d]\n", wood_point.x, wood_point.y
    #   dist = @point.distance(wood_point)
    #   world.push(GetWoodCommand.new(@point))
    # else
    #   printf "no wood tile\n"
    # end
    return BASE_TIME
  end

  def finish(world : World)
    world.push(GetWoodCommand.new(@point))
    # res = world.resources
    # res.add_wood(10)
    # wood_point = world.map.nearest_wood(@point)
    # if !wood_point.nil?
    #   printf "cut down wood at [%d,%d]\n", wood_point.x, wood_point.y
    #   dist = @point.distance(wood_point)
    #   world.push(ts + dist + 5, GetWoodCommand.new(@point))
    # else
    #   printf "no wood tile\n"
    # end
  end
end

class World
  def initialize
    @ts = 0
    @resources = Resources.new
    @map = Map.new
    @queue = App::CommandQueue.new
  end

  def ts
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
w.run(45)
