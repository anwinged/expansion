require "./exception"

enum Game::ResourceType
  Crystal
  Terraformation
end

class Game::Resources
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
    new_value = @values[t] + value
    if new_value < 0
      raise NotEnoughtResources.new
    end
    @values[t] = new_value
  end

  def dec(t : ResourceType, value : Int32)
    inc(t, -value)
  end
end
