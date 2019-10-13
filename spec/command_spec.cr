require "./spec_helper"

describe Game::Command do
  it "should complete build command" do
    world = Game::World.new create_map_2x2
    point = Game::Point.new 1, 0
    building = Game::Building.new Game::Building::Type::StartPoint, **{
      construction: Game::Construction.free 10,
    }
    command = Game::BuildCommand.new point, building
    world.push command
    tile = world.map.get point
    tile.should be_a(Game::ConstructionSiteTile)
    world.run 10
    tile = world.map.get point
    tile.should be_a(Game::BuildingTile)
  end

  it "should restrict build if not enought resources" do
    world = Game::World.new create_map_2x2
    point = Game::Point.new 1, 0
    building = Game::Building.new Game::Building::Type::StartPoint, **{
      construction: Game::Construction.new(
        ts: 10,
        cost: Game::Resources.new({
          Game::Resources::Type::Crystals => 100,
        }),
        requirements: [] of Game::Building::Type
      ),
    }
    command = Game::BuildCommand.new point, building
    expect_raises(Game::NotEnoughtResources) do
      world.push(command)
    end
  end
end
