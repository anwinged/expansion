require "./tile"

module Game
  abstract class Command
    abstract def start(world : World) : Int32
    abstract def finish(world : World)
    abstract def desc : String
  end

  class BuildCrystalHarvesterCommand < Command
    BUILD_TIME = 30

    def initialize(@point : Point)
    end

    def start(world : World) : Int32
      world.map.set(ConstructionSiteTile.new(@point))
      BUILD_TIME
    end

    def finish(world : World)
      world.map.set(CrystalHarvesterTile.new(@point))
      world.push(HarvestCrystalCommand.new(@point))
    end

    def desc : String
      sprintf "Build harvester site at %d,%d", @point.x, @point.y
    end
  end

  class HarvestCrystalCommand < Command
    HARVEST_VALUE = 80
    HARVEST_TIME  = 10
    REST_TIME     =  5

    def initialize(@point : Point)
      @value = 0
    end

    def start(world : World) : Int32
      deposit_tile = nearest_deposit(world)
      stock_tile = nearest_stock(world)
      if deposit_tile && stock_tile
        wood_dist = @point.distance(deposit_tile.point)
        stock_dist = @point.distance(stock_tile.point)
        @value = deposit_tile.withdraw(HARVEST_VALUE)
        HARVEST_TIME + 2 * wood_dist + 2 * stock_dist
      else
        REST_TIME
      end
    end

    def finish(world : World)
      world.resources.inc(ResourceType::Crystal, @value)
      world.push(HarvestCrystalCommand.new(@point))
    end

    def desc : String
      sprintf "Harvest crystals at %d,%d", @point.x, @point.y
    end

    private def nearest_deposit(world : World)
      world.map.nearest_tile @point do |tile|
        tile.has_role(TileRole::CrystalDeposits) && tile.cur > 0
      end
    end

    private def nearest_stock(world : World)
      world.map.nearest_tile @point do |tile|
        tile.has_role(TileRole::Warehouse)
      end
    end
  end

  class BuildCrystalRestorerCommand < Command
    CRYSTALS_COST = 100
    BUILD_TIME    =  50

    def initialize(@point : Point)
    end

    def start(world : World) : Int32
      world.resources.dec(ResourceType::Crystal, CRYSTALS_COST)
      world.map.set(ConstructionSiteTile.new(@point))
      BUILD_TIME
    end

    def finish(world : World)
      world.map.set(CrystalRestorerTile.new(@point))
      world.push(RestoreCrystalCommand.new(@point))
    end

    def desc : String
      sprintf "Build crystal restorer at %d,%d", @point.x, @point.y
    end
  end

  class RestoreCrystalCommand < Command
    RESTORE_TIME  = 15
    RESTORE_VALUE = 30
    REST_TIME     =  5

    @target_tile : Tile | Nil = nil

    def initialize(@point : Point)
    end

    def start(world : World) : Int32
      @target_tile = nearest_deposit(world)
      if @target_tile
        dist = @point.distance(@target_tile.as(Tile).point)
        RESTORE_TIME + 2 * dist
      else
        REST_TIME
      end
    end

    def finish(world : World)
      if @target_tile
        @target_tile.as(Tile).charge(RESTORE_VALUE)
      end
      world.push(RestoreCrystalCommand.new(@point))
    end

    def desc : String
      sprintf "Restore crystals at %d,%d", @point.x, @point.y
    end

    private def nearest_deposit(world : World)
      world.map.nearest_tile @point do |tile|
        tile.has_role(TileRole::CrystalDeposits) && tile.cur < tile.cap
      end
    end
  end

  class BuildTerraformerCommand < Command
    CRYSTALS_COST = 100
    BUILD_TIME    = 120

    def initialize(@point : Point)
    end

    def start(world : World) : Int32
      world.map.set(ConstructionSiteTile.new(@point))
      world.resources.dec(ResourceType::Crystal, CRYSTALS_COST)
      BUILD_TIME
    end

    def finish(world : World)
      world.map.set(TerraformerTile.new(@point))
      world.push(TerraformCommand.new(@point))
    end

    def desc : String
      sprintf "Build terraformer at %d,%d", @point.x, @point.y
    end
  end

  class TerraformCommand < Command
    PRODUCTION_TIME  = 60
    PRODUCTION_VALUE =  5

    def initialize(@point : Point)
    end

    def start(world : World) : Int32
      PRODUCTION_TIME
    end

    def desc : String
      "Terraform planet"
    end

    def finish(world : World)
      world.resources.inc(ResourceType::Terraformation, PRODUCTION_VALUE)
      world.push(TerraformCommand.new(@point))
    end
  end
end
