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
      add_amounts vals
    end
  end

  def [](res_type : Resource::Type)
    @values[res_type]
  end

  def has(res_type : Resource::Type, value : Capacity) : Bool
    @values[res_type] >= value
  end

  def has(res : Resource) : Bool
    has res.type, res.amount
  end

  def has(vs : ResourceHash) : Bool
    has_amounts vs
  end

  def has(vs : self) : Bool
    has_amounts vs.@values
  end

  def inc(res_type : Resource::Type, value : Capacity)
    validate_add_amounts ({res_type => value})
    @values[res_type] += value
  end

  def inc(res : Resource)
    inc res.type, res.amount
  end

  def inc(vs : ResourceHash)
    validate_add_amounts vs
    add_amounts vs
  end

  def inc(other : self)
    inc other.@values
  end

  def dec(res_type : Resource::Type, value : Capacity)
    inc res_type, -value
  end

  def dec(other : self)
    inverted = other.@values.transform_values { |v| -v }
    inc inverted
  end

  private def can_add_amounts(vs : ResourceHash)
    vs.reduce true do |acc, entry|
      res_type, amount = entry
      acc && @values[res_type] + amount >= 0
    end
  end

  private def validate_add_amounts(vs : ResourceHash)
    if !can_add_amounts(vs)
      raise NotEnoughtResources.new
    end
  end

  private def add_amounts(vs : ResourceHash)
    vs.each do |entry|
      res_type, amount = entry
      @values[res_type] += amount
    end
  end

  private def has_amounts(vs : ResourceHash)
    vs.reduce true do |acc, entry|
      res_type, amount = entry
      acc && @values[res_type] >= amount
    end
  end
end
