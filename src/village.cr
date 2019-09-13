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

class World
  def initialize
    @resources = Resources.new
    @queue = Array(Command).new
  end

  def resources
    @resources
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

q = World.new
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(2))
q.run(10)
