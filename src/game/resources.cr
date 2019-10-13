require "./types"

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

  def [](res_type : Resource::Type)
    @values.fetch(res_type, 0)
  end

  def has(res_type : Resource::Type, value : Capacity) : Bool
    @values[res_type] >= value
  end

  def has(res : Resource) : Bool
    has(res.type, res.amount)
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

  def inc(res_type : Resource::Type, value : Capacity)
    new_value = @values[res_type] + value
    if new_value < 0
      raise NotEnoughtResources.new
    end
    @values[res_type] = new_value
  end

  def inc(res : Resource)
    inc(res.type, res.amount)
  end

  def dec(res_type : Resource::Type, value : Capacity)
    inc(res_type, -value)
  end

  def to_hash : ResourceHash
    @values.clone
  end
end
