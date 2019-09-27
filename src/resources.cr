enum ResourceType
  Crystal
  Terraformation
end

class Resources
  def initialize
    @values = {} of ResourceType => Int32
    ResourceType.each do |t|
      @values[t] = 0
    end
  end

  def [](t : ResourceType)
    @values[t]
  end

  def inc(t : ResourceType, value : Int32)
    @values[t] = @values[t] + value
  end
end
