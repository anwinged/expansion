require "colorize"
require "./command"
require "./map"
require "./queue"

enum ResourceType
  Crystal
  Terraformation
end

class Resources
  def initialize
    @values = {} of ResourceType => Int32
    ResourceType.each do |t|
      @values[t] = 0
    end
  end

  def [](t : ResourceType)
    @values[t]
  end

  def inc(t : ResourceType, value : Int32)
    @values[t] = @values[t] + value
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
w.push(BuildCrystalHarvesterCommand.new(Point.new(2, 3)))
w.push(BuildCrystalRestorerCommand.new(Point.new(1, 2)))
w.push(BuildCrystalRestorerCommand.new(Point.new(3, 2)))
w.run(60)
w.map.print
pp w.resources
