require "colorize"
require "./command"
require "./map"
require "./queue"

class Resources
  def initialize(@wood = 0)
  end

  def add_wood(x)
    @wood += x
  end

  def wood
    @wood
  end
end

class World
  def initialize
    @ts = 0
    @resources = Resources.new
    @map = Map.new
    @queue = App::Queue.new
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
      command = item.command
      @ts = item.ts
      command.finish(self)
      printf "world : %d : finish `%s`\n", @ts, typeof(command)
    end
  end
end

w = World.new
w.map.print
w.push(BuildWoodMillCommand.new(Point.new(2, 3)))
w.push(BuildForesterHouseCommand.new(Point.new(1, 2)))
w.push(BuildForesterHouseCommand.new(Point.new(3, 2)))
w.run(120)
w.map.print
printf "Wood: %d\n", w.resources.wood
