class Game::Deposit
  @cur : Capacity = 0

  def initialize(@type : Resource::Type, @cap : Capacity)
    @cur = @cap
  end

  def initialize(@type : Resource::Type, @cap : Capacity, @cur : Capacity)
  end

  getter type
  getter cap
  getter cur

  def inc(resource : Resource)
    check_res resource.type
    @cur = Math.min(@cap, @cur + resource.amount)
  end

  def dec(resource : Resource)
    check_res resource.type
    @cur = Math.max(0, @cur - resource.amount)
  end

  private def check_res(other_res_type : Resource::Type)
    if @type != other_res_type
      raise ResourceMismatch.new
    end
  end
end
