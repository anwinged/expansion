require "./tile"

module Game
  abstract class Command
    abstract def start(world : World) : TimeSpan
    abstract def finish(world : World)
    abstract def desc : String
  end

  class BuildCommand < Command
    def initialize(@point : Point, @building : Building)
    end

    def desc : String
      sprintf "Building '%s'", @building.name
    end

    def start(world : World) : TimeSpan
      construction = @building.construction
      if !world.resources.has(construction.cost)
        raise NotEnoughtResources.new
      end
      tile = world.map.get @point
      if !tile.as?(PlateauTile)
        raise InvalidPlaceForBuilding.new
      end
      # @todo check requirements
      world.map.set(ConstructionSiteTile.new(@point))
      construction.ts
    end

    def finish(world : World)
      world.map.set(BuildingTile.new(@point, @building))
      if @building.mining
        world.push(MineCommand.new(@point))
      end
      if @building.restoration
        world.push(RestoreCommand.new(@point))
      end
      if @building.production
        world.push(ProduceCommand.new(@point))
      end
    end
  end

  abstract class ResourceCommand < Command
    def initialize(@point : Point, *, @once = false)
    end

    protected def nearest_stock(world : World) : BuildingTile?
      tile = world.map.nearest_tile @point do |t|
        t.is_a?(BuildingTile) && t.building.has_role Building::Role::Storehouse
      end
      tile.as?(BuildingTile)
    end
  end

  class MineCommand < ResourceCommand
    @holded : Resource? = nil

    def desc : String
      if @holded
        sprintf "Mine %s from %d,%d", @holded.as(Resource).type, @point.x, @point.y
      else
        sprintf "Wait for resources at %d,%d", @point.x, @point.y
      end
    end

    def start(world : World) : TimeSpan
      tile = world.map.get(@point).as(BuildingTile)
      building = tile.building
      mining = building.mining.as(Mining)
      if !world.resources.has(mining.input)
        return mining.ts
      end
      resource = mining.resource
      deposit_tile = nearest_deposit(world, resource.type)
      stock_tile = nearest_stock(world)
      if deposit_tile && stock_tile
        mined_amount = deposit_tile.dep.dec(resource.amount)
        @holded = resource.type.to_res mined_amount
        mining.ts +
          2 * tile.point.distance(stock_tile.point) +
          2 * tile.point.distance(deposit_tile.point)
      else
        mining.ts
      end
    end

    def finish(world : World)
      if @holded
        holded = @holded.as(Resource)
        world.resources.inc(holded)
      end
      if !@once
        world.push(MineCommand.new(@point))
      end
    end

    private def nearest_deposit(world : World, res_type : Resource::Type) : DepositTile?
      tile = world.map.nearest_tile @point do |t|
        t.is_a?(DepositTile) && t.dep.type == res_type && t.dep.cur > 0
      end
      tile.as?(DepositTile)
    end
  end

  class RestoreCommand < ResourceCommand
    @holded : Resource? = nil
    @deposit_tile : DepositTile? = nil

    def desc : String
      if @holded
        sprintf "Restore %s from %d,%d", @holded.as(Resource).type, @point.x, @point.y
      else
        sprintf "Wait for resources at %d,%d", @point.x, @point.y
      end
    end

    def start(world : World) : TimeSpan
      tile = world.map.get(@point).as(BuildingTile)
      building = tile.building
      restoration = building.restoration.as(Mining)
      if !world.resources.has(restoration.input)
        return restoration.ts
      end
      resource = restoration.resource
      @deposit_tile = nearest_deposit(world, resource.type)
      stock_tile = nearest_stock(world)
      if @deposit_tile && stock_tile
        world.resources.dec restoration.input
        @holded = resource
        restoration.ts +
          2 * tile.point.distance(stock_tile.point) +
          2 * tile.point.distance(@deposit_tile.as(DepositTile).point)
      else
        restoration.ts
      end
    end

    def finish(world : World)
      if @deposit_tile && @holded
        @deposit_tile.as(DepositTile).dep.inc(@holded.as(Resource).amount)
      end
      if !@once
        world.push(RestoreCommand.new(@point))
      end
    end

    private def nearest_deposit(world : World, res_type : Resource::Type) : DepositTile?
      tile = world.map.nearest_tile @point do |t|
        t.is_a?(DepositTile) && t.dep.type == res_type && t.dep.cur == 0
      end
      tile.as?(DepositTile)
    end
  end

  class ProduceCommand < ResourceCommand
    @holded : ResourceBag? = nil

    def desc : String
      if @holded
        sprintf "Produce at %d,%d", @point.x, @point.y
      else
        sprintf "Wait for resources at %d,%d", @point.x, @point.y
      end
    end

    def start(world : World) : TimeSpan
      tile = world.map.get(@point).as(BuildingTile)
      building = tile.building
      production = building.production.as(Production)
      if !world.resources.has(production.input)
        return production.ts
      end
      stock_tile = nearest_stock(world)
      if stock_tile
        world.resources.dec production.input
        @holded = production.output
        production.ts + 4 * tile.point.distance(stock_tile.point)
      else
        production.ts
      end
    end

    def finish(world : World)
      if @holded
        world.resources.inc @holded.as(ResourceBag)
      end
      if !@once
        world.push(ProduceCommand.new(@point))
      end
    end
  end
end
