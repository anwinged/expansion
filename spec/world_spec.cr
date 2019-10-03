require "./spec_helper"
require "../src/game/world"

describe "World" do
  it "should build crystal harvester" do
    world = World.new
    point = Point.new(2, 3)
    cmd = BuildCrystalHarvesterCommand.new(point)
    world.push(cmd)
    world.run(100)
    world.map.get(point).has_role(TileRole::CrystalHarvester)
  end

  it "should fail when not enought resources" do
    world = World.new
    point = Point.new(2, 3)
    cmd = BuildCrystalRestorerCommand.new(point)
    expect_raises(NotEnoughtResources) do
      world.push(cmd)
    end
  end
end
