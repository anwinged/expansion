module Game
  class Production
    def initialize(@ts : TimeSpan, @input : ResourceBag, @output : ResourceBag)
    end

    getter ts
    getter input
    getter output
  end

  class Mining
    def initialize(@ts : TimeSpan, @resource : Resource, @input : ResourceBag, @deposit : Bool = true)
    end

    getter ts
    getter resource
    getter input
    getter deposit
  end

  class Construction
    def initialize(
      @ts : TimeSpan,
      @cost : ResourceBag,
      @requirements : Array(Building::Type) = [] of Building::Type
    )
    end

    getter ts
    getter cost
    getter requirements

    def self.immediatly
      Construction.new 0, ResourceBag.new
    end

    def self.free(ts : TimeSpan)
      Construction.new ts, ResourceBag.new
    end
  end

  class Building
    enum Role
      Storehouse
    end

    enum Type
      StartPoint
      CrystalMiner
      CrystalRestorer
      OxygenCollector
      Terraformer
    end

    def initialize(
      @type : Type,
      *,
      name : String = "",
      roles : Array(Role) | Nil = nil,
      construction : Construction | Nil = nil,
      production : Production | Nil = nil,
      mining : Mining | Nil = nil,
      restoration : Mining | Nil = nil,
      storage : Capacity | Nil = nil,
      shortcut : String = ""
    )
      @name = name != "" ? name : @type.to_s
      @roles = roles.nil? ? Array(Role).new : roles.as(Array(Role))
      @construction = construction.nil? ? Construction.immediatly : construction.as(Construction)
      @production = production
      @mining = mining
      @restoration = restoration
      @storage = storage.nil? ? 0 : storage
      @shortcut = shortcut
    end

    getter type
    getter name
    getter roles
    getter construction
    getter production
    getter mining
    getter restoration
    getter storage
    getter shortcut

    def has_role(role : Role) : Bool
      @roles.includes? role
    end
  end
end
