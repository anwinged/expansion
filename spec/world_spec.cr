require "./spec_helper"
require "../src/game/world"

describe "World" do
  it "should build crystal harvester" do
    map = Game::Generator.make 5, 5
    world = Game::World.new map
    point = Game::Point.new 2, 3
    cmd = Game::BuildCrystalHarvesterCommand.new(point)
    world.push(cmd)
    world.run(100)
    world.map.get(point).has_role(Game::TileRole::CrystalHarvester)
  end

  it "should fail when not enought resources" do
    map = Game::Generator.make 5, 5
    world = Game::World.new map
    point = Game::Point.new 2, 3
    cmd = Game::BuildCrystalRestorerCommand.new(point)
    expect_raises(Game::NotEnoughtResources) do
      world.push(cmd)
    end
  end
end
