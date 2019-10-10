require "./exception"

class Game::Resources
  enum Type
    Crystals
    Terraformation
  end

  def initialize
    @values = {} of Type => Int32
  end

  def initialize(vals : Hash(Type, Int32))
    @values = vals.clone
  end

  def [](t : Type)
    @values.fetch(t, 0)
  end

  def has(t : Type, value : Int32) : Bool
    @values.fetch(t, 0) >= value
  end

  def inc(t : Type, value : Int32)
    new_value = @values.fetch(t, 0) + value
    if new_value < 0
      raise NotEnoughtResources.new
    end
    @values[t] = new_value
  end

  def dec(t : Type, value : Int32)
    inc(t, -value)
  end
end
