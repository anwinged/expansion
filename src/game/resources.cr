require "./exception"

struct Game::Resource
  enum Type
    Crystals
    Terraformation
  end

  def initialize(@type : Type, @amount : Capacity)
  end

  getter type
  getter amount

  def with_amount(amount : Capacity) : self
    self.new @type, amount
  end
end

class Game::ResourceBag
  alias ResourceHash = Hash(Resource::Type, Capacity)

  @values : ResourceHash

  def initialize(vals : ResourceHash | Nil = nil)
    @values = ResourceHash.new
    Resource::Type.each { |t, v| @values[t] = 0 }
    if vals.is_a?(ResourceHash)
      vals.each do |i|
        t, v = i
        @values[t] = v
      end
    end
  end

  def [](t : Resource::Type)
    @values.fetch(t, 0)
  end

  def has(t : Resource::Type, value : Capacity) : Bool
    @values[t] >= value
  end

  def has(vs : ResourceHash) : Bool
    vs.reduce true do |acc, entry|
      t = entry[0]
      v = entry[1]
      acc && @values[t] >= v
    end
  end

  def has(vs : self) : Bool
    has vs.to_hash
  end

  def inc(t : Resource::Type, value : Capacity)
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

  def dec(t : Resource::Type, value : Capacity)
    inc(t, -value)
  end

  def to_hash : ResourceHash
    @values.clone
  end
end
