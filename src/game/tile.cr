module Game
  enum TileRole
    ConstructionSite
    CrystalDeposits
    CrystalHarvester
    CrystalRestorer
    Plateau
    Terraformer
    Warehouse
    Building
  end

  abstract class Tile
    property cap : Int32 = 0
    property cur : Int32 = 0

    def initialize(@point : Point)
    end

    getter point
    getter cap
    getter cur

    abstract def has_role(role : TileRole) : Bool

    def letter : Char
      ' '
    end

    def withdraw(value)
      if value >= @cur
        wd = @cur
        @cur = 0
        wd
      else
        @cur -= value
        value
      end
    end

    def charge(value)
      charged = @cur + value
      @cur = charged <= @cap ? charged : @cap
    end

    def can_build?
      has_role(TileRole::Plateau)
    end
  end

  class PlateauTile < Tile
    def letter : Char
      ' '
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::Plateau
    end
  end

  class ConstructionSiteTile < Tile
    def letter : Char
      '_'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::ConstructionSite
    end
  end

  class MainBaseTile < Tile
    def letter : Char
      'W'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::Warehouse
    end
  end

  class CrystalTile < Tile
    def initialize(@point : Point, cap : Int32)
      @cap = cap
      @cur = cap
    end

    def letter : Char
      'v'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::CrystalDeposits
    end
  end

  class CrystalHarvesterTile < Tile
    def letter : Char
      'H'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::CrystalHarvester
    end
  end

  class CrystalRestorerTile < Tile
    def letter : Char
      'R'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::CrystalRestorer
    end
  end

  class TerraformerTile < Tile
    def letter : Char
      'T'
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::Terraformer
    end
  end

  class BuildingTile < Tile
    def initialize(@point : Point, @building : Building)
    end

    def has_role(role : TileRole) : Bool
      role == TileRole::Building
    end

    getter building
  end
end
