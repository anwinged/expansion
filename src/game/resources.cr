require "./exception"

class Game::Resources
  enum Type
    Crystals
    Terraformation
  end

  alias Capacity = Int32

  def initialize
    @values = {} of Type => Capacity
  end

  def initialize(vals : Hash(Type, Capacity))
    @values = vals.clone
  end

  def [](t : Type)
    @values.fetch(t, 0)
  end

  def has(t : Type, value : Capacity) : Bool
    @values.fetch(t, 0) >= value
  end

  def inc(t : Type, value : Capacity)
    new_value = @values.fetch(t, 0) + value
    if new_value < 0
      raise NotEnoughtResources.new
    end
    @values[t] = new_value
  end

  def dec(t : Type, value : Capacity)
    inc(t, -value)
  end
end
