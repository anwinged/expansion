module Game
  abstract class Tile
    def initialize(@point : Point)
    end

    getter point
  end

  class PlateauTile < Tile
  end

  class ConstructionSiteTile < Tile
  end

  class BuildingTile < Tile
    def initialize(@point : Point, @building : Building)
    end

    getter building
  end

  class DepositTile < Tile
    def initialize(@point : Point, @dep : Deposit)
    end

    getter dep
  end
end
