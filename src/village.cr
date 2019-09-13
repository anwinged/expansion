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

  abstract def run(queue : CommandQueue, res : Resources)
end

class BuildMillCommand < Command
  def run(queue : CommandQueue, res : Resources)
    puts "build mill"
    c = GetWoodCommand.new(@ts + 5)
    queue.push(c)
  end
end

class GetWoodCommand < Command
  def run(queue : CommandQueue, res : Resources)
    res.add_wood(10)
    puts "get wood"
    c = GetWoodCommand.new(@ts + 5)
    queue.push(c)
  end
end

class CommandQueue
  def initialize
    @resources = Resources.new
    @data = Array(Command).new
  end

  def push(command : Command)
    printf "push command %d\n", command.ts
    @data.push(command)
    @data.sort! do |c|
      -c.ts
    end
  end

  def run(ts : Int32)
    while @data.size != 0
      c = @data.pop
      printf "pop command %d\n", c.ts
      if c.ts > ts
        break
      end
      c.run(self, @resources)
    end
    printf "Wood: %d\n", @resources.wood
  end
end

q = CommandQueue.new
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(0))
q.push(BuildMillCommand.new(2))
q.run(10)
