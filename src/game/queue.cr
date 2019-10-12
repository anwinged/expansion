class Game::Queue
  struct Item
    def initialize(@ts : TimePoint, @command : Command)
    end

    getter ts
    getter command
  end

  def initialize
    @data = [] of Item
  end

  def push(ts : TimePoint, value : Command)
    # very unoptimal algo
    @data.push(Item.new(ts, value))
    @data.sort! do |a, b|
      b.ts <=> a.ts
    end
  end

  def pop(ts : TimePoint) : Item | Nil
    if @data.size == 0
      return nil
    end
    @data[-1].ts <= ts ? @data.pop : nil
  end

  def top(n : Int32)
    @data.last(n).reverse!
  end
end
