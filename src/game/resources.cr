require "./exception"

class Game::Resources
  enum Type
    Crystals
    Terraformation
  end

  alias ResourceBag = Hash(Type, Capacity)

  @values : ResourceBag

  def initialize(vals : ResourceBag | Nil = nil)
    @values = {} of Type => Capacity
    Type.each { |t, v| @values[t] = 0 }
    if vals.is_a?(ResourceBag)
      vals.each do |i|
        t, v = i
        @values[t] = v
      end
    end
  end

  def [](t : Type)
    @values.fetch(t, 0)
  end

  def has(t : Type, value : Capacity) : Bool
    @values[t] >= value
  end

  def has(vs : ResourceBag) : Bool
    vs.reduce true do |acc, entry|
      t = entry[0]
      v = entry[1]
      acc && @values[t] >= v
    end
  end

  def has(vs : self) : Bool
    has vs.to_hash
  end

  def inc(t : Type, value : Capacity)
    new_value = @values.fetch(t, 0) + value
    if new_value < 0
      raise NotEnoughtResources.new
    end
    @values[t] = new_value
  end

  def inc?(vs : ResourceBag) : Bool
    false unless has(vs)
    vs.each do |t, c|
      @values[t] = @values[t] + c
    end
    true
  end

  def dec(t : Type, value : Capacity)
    inc(t, -value)
  end

  def to_hash : ResourceBag
    @values.clone
  end
end
