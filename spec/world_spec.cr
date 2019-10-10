require "./spec_helper"

describe "World" do
  it "should build crystal harvester" do
    world = Game::World.new create_map_2x2
    point = Game::Point.new 1, 0
    cmd = Game::BuildCrystalHarvesterCommand.new(point)
    world.push(cmd)
    world.run(100)
    world.map.get(point).has_role(Game::TileRole::CrystalHarvester)
  end

  it "should fail when not enought resources" do
    world = Game::World.new create_map_2x2
    point = Game::Point.new 1, 0
    cmd = Game::BuildCrystalRestorerCommand.new(point)
    expect_raises(Game::NotEnoughtResources) do
      world.push(cmd)
    end
  end
end
