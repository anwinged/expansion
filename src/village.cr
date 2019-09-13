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
  def initialize(ts : Int32)
    @ts = ts
  end

  def ts
    @ts
  end

  abstract def supports?(world : World) : Bool
  abstract def run(world : World)
end

class BuildMillCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(world : World)
    puts "build mill"
    c = GetWoodCommand.new(@ts + 5)
    world.push(c)
  end
end

class BuildForesterHouseCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(world : World)
    puts "build forester house"
    c = GrowWoodCommand.new(@ts + 10)
    world.push(c)
  end
end

class GetWoodCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(world : World)
    res = world.resources
    res.add_wood(10)
    puts "get wood"
    c = GetWoodCommand.new(@ts + 5)
    world.push(c)
  end
end

class GrowWoodCommand < Command
  def supports?(world : World) : Bool
    return true
  end

  def run(world : World)
    res = world.resources
    puts "grow wood"
    c = GetWoodCommand.new(@ts + 5)
    world.push(c)
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
    @queue = Array(Command).new
  end

  def resources
    @resources
  end

  def map
    @map
  end

  def push(command : Command) : Bool
    if !command.supports?(self)
      return false
    end
    printf "push command %d\n", command.ts
    @queue.push(command)
    @queue.sort! do |c|
      -c.ts
    end
    true
  end

  def run(ts : Int32)
    while @queue.size != 0
      c = @queue.pop
      printf "pop command %d\n", c.ts
      if c.ts > ts
        break
      end
      c.run(self)
    end
    printf "Wood: %d\n", @resources.wood
  end
end

w = World.new
w.map.print
w.push(BuildMillCommand.new(0))
w.push(BuildForesterHouseCommand.new(0))
w.run(100)
