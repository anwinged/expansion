class App::CommandQueue
  def initialize
  end

  def push(ts : Int32, cmd : Command)
  end

  def pop(ts : Int32) : Command | Nil
  end
end
