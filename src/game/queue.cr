class App::Queue
  struct Item
    def initialize(@ts : Int32, @command : Command)
    end

    getter ts
    getter command
  end

  def initialize
    @data = [] of Item
  end

  def push(ts : Int32, value : Command)
    # very unoptimal algo
    @data.push(Item.new(ts, value))
    @data.sort! do |a, b|
      b.ts <=> a.ts
    end
  end

  def pop(ts : Int32) : Item | Nil
    if @data.size == 0
      return nil
    end
    @data[-1].ts <= ts ? @data.pop : nil
  end
end
