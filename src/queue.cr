class App::Queue(T)
  struct Item(T)
    def initialize(@ts : Int32, @value : T)
    end

    getter ts
    getter value
  end

  def initialize
    @data = [] of Item(T)
  end

  # Plan finishing of *command* at time *ts*
  def push(ts : Int32, value : T)
    @data.push(Item.new(ts, value))
    @data.sort! do |a, b|
      b.ts <=> a.ts
    end
  end

  def pop(ts : Int32) : Item(T) | Nil
    if @data.size == 0
      return nil
    end
    @data[-1].ts <= ts ? @data.pop : nil
  end
end
