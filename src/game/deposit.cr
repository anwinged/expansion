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

  def inc(resource : Resource) : Resource
    check_res resource.type
    if @cur + resource.amount <= @cap
      @cur += resource.amount
      Resource.new(resource.type, resource.amount)
    else
      res = Resource.new(resource.type, @cap - @cur)
      @cur = @cap
      res
    end
  end

  def dec(resource : Resource) : Resource
    check_res resource.type
    if @cur >= resource.amount
      @cur -= resource.amount
      resource
    else
      res = Resource.new(resource.type, @cur)
      @cur = 0
      res
    end
  end

  private def check_res(other_res_type : Resource::Type)
    if @type != other_res_type
      raise ResourceMismatch.new
    end
  end
end
