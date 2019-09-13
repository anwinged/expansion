require "./queue"

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

class BuildMillCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(ts : Int32, world : World)
    puts "build mill"
    c = GetWoodCommand.new
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

class Map
  def initialize
    @data = {} of String => Tile
    (0...4).each do |x|
      (0...4).each do |y|
        @data[key(x, y)] = GrassTile.new
      end
    end
    @data[key(1, 1)] = WoodTile.new(100)
    @data[key(3, 1)] = WoodTile.new(200)
    @data[key(2, 2)] = WoodTile.new(100)
  end

  def get(x : Int32, y : Int32) : Tile
    @data[key(x, y)]
  end

  def print
    (0...4).each do |x|
      (0...4).each do |y|
        printf "%c", @data[key(x, y)].letter
      end
      printf "\n"
    end
  end

  private def key(x : Int32, y : Int32) : String
    return sprintf "%d:%d", x, y
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
    printf "push command %d\n", ts
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
w.push(0, BuildMillCommand.new)
w.push(1, BuildForesterHouseCommand.new)
w.run(20)
