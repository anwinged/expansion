class Game::MapGenerator
  def self.make(rows, cols, deposits = 5) : Map
    rnd = Random.new
    map = Map.new(rows, cols)
    deposits.times do
      point = Point.new(rnd.rand(0...rows), rnd.rand(0...cols))
      cap = rnd.rand(2...6)
      deposit = Deposit.new(Resource::Type::Crystals, cap * 50)
      map.set DepositTile.new(point, deposit)
    end
    map
  end
end
