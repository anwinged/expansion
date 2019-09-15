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
  abstract def supports?(world : World) : Bool
  abstract def run(ts : Int32, world : World)
end

class BuildWoodMillCommand < Command
  def initialize(@point : Point)
  end

  def supports?(world : World) : Bool
    return true
  end

  def run(ts : Int32, world : World)
    printf "build mill at [%d,%d]\n", @point.x, @point.y
    c = GetWoodCommand.new
    world.map.set(@point, WoodMillTile.new)
    world.push(ts + 5, c)
  end
end

class BuildForesterHouseCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(ts : Int32, world : World)
    puts "build forester house"
    c = GrowWoodCommand.new
    world.push(ts + 10, c)
  end
end

class GetWoodCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(ts : Int32, world : World)
    res = world.resources
    res.add_wood(10)
    puts "get wood"
    c = GetWoodCommand.new
    world.push(ts + 5, c)
  end
end

class GrowWoodCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(ts : Int32, world : World)
    res = world.resources
    puts "grow wood"
    c = GetWoodCommand.new
    world.push(ts + 5, c)
  end
end

class World
  def initialize
    @resources = Resources.new
    @map = Map.new
    @queue = App::CommandQueue.new
  end

  def resources
    @resources
  end

  def map
    @map
  end

  def push(ts : Int32, command : Command) : Bool
    if !command.supports?(self)
      return false
    end
    printf "push command %s, %d\n", typeof(command), ts
    @queue.push(ts, command)
    true
  end

  def run(ts : Int32)
    loop do
      item = @queue.pop(ts)
      if item.nil?
        break
      end
      printf "pop command %d\n", item[:ts]
      item[:cmd].run(item[:ts], self)
    end
    printf "Wood: %d\n", @resources.wood
  end
end

w = World.new
w.map.print
w.push(0, BuildWoodMillCommand.new(Point.new(0, 0)))
w.push(1, BuildForesterHouseCommand.new)
w.run(20)
w.map.print
