class Game::Deposit
  @cap : Capacity = 0
  @cur : Capacity = 0

  def initialize(@type : Resource::Type, @cap : Capacity)
    @cur = @cap
  end

  def initialize(@type : Resource::Type, @cap : Capacity, @cur : Capacity)
  end

  getter type
  getter cap
  getter cur

  def inc(value : Capacity) : Capacity
    if @cur + value <= @cap
      @cur += value
      value
    else
      res = @cap - @cur
      @cur = @cap
      res
    end
  end

  def dec(value : Capacity) : Capacity
    if @cur >= value
      @cur -= value
      value
    else
      res = @cur
      @cur = 0
      res
    end
  end
end
