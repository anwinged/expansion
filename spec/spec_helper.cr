require "spec"
require "../src/game/**"
require "../src/cli/**"

def create_map_2x2 : Game::Map
  map = Game::Map.new 2, 2
  map.set(Game::MainBaseTile.new(Game::Point.new(0, 0)))
  map.set(Game::CrystalTile.new(Game::Point.new(1, 1), 100))
  map
end
