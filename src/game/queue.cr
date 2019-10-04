class Game::Queue
  struct Item
    def initialize(@ts : Int64, @command : Game::Command)
    end

    getter ts
    getter command
  end

  def initialize
    @data = [] of Item
  end

  def push(ts : Int64, value : Game::Command)
    # very unoptimal algo
    @data.push(Item.new(ts, value))
    @data.sort! do |a, b|
      b.ts <=> a.ts
    end
  end

  def pop(ts : Int64) : Item | Nil
    if @data.size == 0
      return nil
    end
    @data[-1].ts <= ts ? @data.pop : nil
  end
end
