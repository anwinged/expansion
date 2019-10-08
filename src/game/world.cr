require "./resources"

class Game::World
  property ts : Int64
  property win_ts : Int64?

  def initialize(@ts = 0_i64)
    @map = Map.new
    @resources = Resources.new
    @queue = Queue.new
  end

  getter ts
  getter resources
  getter map
  getter queue
  getter win_ts

  def push(command : Command)
    dur = command.start(self)
    done_at = @ts + dur.to_i64
    @queue.push(done_at, command)
  end

  def run(ts : Int64)
    loop do
      item = @queue.pop(ts)
      if item.nil?
        break
      end
      command = item.command
      @ts = item.ts
      command.finish(self)
      if win?
        @win_ts = @ts
      end
    end
    @ts = ts
  end

  def win?
    @resources[ResourceType::Terraformation] >= 100
  end

  def score
    case @win_ts
    when Int64
      Math.max(0, 3600_i64 - @win_ts.as(Int64))
    else
      0
    end
  end
end
