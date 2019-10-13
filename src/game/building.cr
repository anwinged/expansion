module Game
  class Production
    def initialize(@ts : TimeSpan, @input : Resources, @output : Resources)
    end

    getter ts
    getter input
    getter output
  end

  class Mining
    def initialize(@ts : TimeSpan, @dep : DepositSpan)
    end

    getter ts
    getter dep
  end

  class Construction
    def initialize(
      @ts : TimeSpan,
      @cost : Resources,
      @requirements : Array(Building::Type) = [] of Building::Type
    )
    end

    getter ts
    getter cost
    getter requirements

    def self.immediatly
      Construction.new 0, Resources.new
    end

    def self.free(ts : TimeSpan)
      Construction.new ts, Resources.new
    end
  end

  class Building
    enum Role
      Storehouse
    end

    enum Type
      StartPoint
      Storehouse
      CrystalMiner
      CrystalRestorer
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
      storage : Capacity | Nil = nil
    )
      @name = name != "" ? name : @type.to_s
      @roles = roles.nil? ? Array(Role).new : roles
      @construction = construction.nil? ? Construction.immediatly : construction.as(Construction)
      @production = production
      @mining = mining
      @restoration = restoration
      @storage = storage.nil? ? 0 : storage
    end

    getter type
    getter name
    getter roles
    getter construction
    getter production
    getter mining
    getter restoration
    getter storage
  end
end
