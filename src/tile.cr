enum TileType
  CrystalDeposits
  CrystalHarvester
  CrystalRestorer
  Plateau
  Warehouse
end

abstract class Tile
  property cap : Int32 = 0
  property cur : Int32 = 0

  def initialize(@point : Point)
  end

  getter point
  getter cap
  getter cur

  abstract def letter : Char
  abstract def type : TileType

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
end

class PlateauTile < Tile
  def letter : Char
    '.'
  end

  def type : TileType
    TileType::Plateau
  end
end

class MainBaseTile < Tile
  def letter : Char
    'H'
  end

  def type : TileType
    TileType::Warehouse
  end
end

class CrystalTile < Tile
  def initialize(@point : Point, cap : Int32)
    @cap = cap
    @cur = cap
  end

  def letter : Char
    'f'
  end

  def type : TileType
    TileType::CrystalDeposits
  end
end

class CrystalHarvesterTile < Tile
  def letter : Char
    'm'
  end

  def type : TileType
    TileType::CrystalHarvester
  end
end

class CrystalRestorerTile < Tile
  def letter : Char
    'h'
  end

  def type : TileType
    TileType::CrystalRestorer
  end
end
