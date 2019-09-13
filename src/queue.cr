class App::CommandQueue
  def initialize
    @data = [] of {Int32, Command}
  end

  def push(ts : Int32, cmd : Command)
    @data.push({ts, cmd})
    @data.sort! do |x|
      -x[0]
    end
  end

  def pop(ts : Int32) : Command | Nil
    if @data.size == 0
      return nil
    end
    last_ts = @data[-1][0]
    if last_ts <= ts
      last_item = @data.pop
      return last_item[1]
    else
      nil
    end
  end
end
