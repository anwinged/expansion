require "./tile"

abstract class Command
  abstract def start(world : World) : Int32
  abstract def finish(world : World)
end

class BuildCrystalHarvesterCommand < Command
  BUILD_TIME = 30

  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    BUILD_TIME
  end

  def finish(world : World)
    harverster = CrystalHarvesterTile.new(@point)
    world.map.set(harverster)
    world.push(HarvestCrystalCommand.new(@point))
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
    world.resources.add_crystal(@value)
    world.push(HarvestCrystalCommand.new(@point))
  end

  private def nearest_deposit(world : World)
    world.map.nearest_tile @point do |tile|
      tile.type == TileType::CrystalDeposits && tile.cur > 0
    end
  end

  private def nearest_stock(world : World)
    world.map.nearest_tile @point do |tile|
      tile.type == TileType::Warehouse
    end
  end
end

class BuildCrystalRestorerCommand < Command
  BUILD_TIME = 50

  def initialize(@point : Point)
  end

  def start(world : World) : Int32
    BUILD_TIME
  end

  def finish(world : World)
    world.map.set(CrystalRestorerTile.new(@point))
    world.push(RestoreCrystalCommand.new(@point))
  end
end

class RestoreCrystalCommand < Command
  RESTORE_TIME  = 15
  RESTORE_VALUE = 30
  REST_TIME     =  5

  @target_tile : Tile | Nil

  def initialize(@point : Point)
    @target_tile = nil
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

  private def nearest_deposit(world : World)
    world.map.nearest_tile @point do |tile|
      tile.type == TileType::CrystalDeposits && tile.cur < tile.cap
    end
  end
end
