class App::CommandQueue
  def initialize
    @data = [] of NamedTuple(ts: Int32, cmd: Command)
  end

  def push(ts : Int32, cmd : Command)
    @data.push({ts: ts, cmd: cmd})
    @data.sort! do |a, b|
      b[:ts] <=> a[:ts]
    end
    # puts @data
  end

  def pop(ts : Int32)
    if @data.size == 0
      return nil
    end
    last_ts = @data[-1][:ts]
    if last_ts <= ts
      return @data.pop
    else
      nil
    end
  end
end
