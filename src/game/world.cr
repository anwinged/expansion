require "./resources"

class Game::World
  property ts : Int64

  def initialize(@map : Map, @ts = 0_i64)
    @start_ts = @ts
    @resources = Resources.new
    @queue = Queue.new
    @finished = false
    @score = 0
  end

  getter ts
  getter resources
  getter map
  getter queue
  getter score

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
      if win? && !@finished
        @finished = true
        @score = Math.max(0, (@start_ts + 3600 - @ts).to_i32)
      end
    end
    @ts = ts
  end

  def win?
    @resources[Resources::Type::Terraformation] >= 100
  end
end
