require "./spec_helper"

module Game::TestCommand
  extend self

  def create_map_2x2 : Map
    map = Map.new 2, 2
    map.set(MainBaseTile.new(Point.new(0, 0)))
    map.set(CrystalTile.new(Point.new(1, 1), 100))
    map
  end

  describe Command do
    it "should complete build command" do
      world = World.new create_map_2x2
      point = Point.new 1, 0
      building = Building.new Building::Type::StartPoint, **{
        construction: Construction.free 10,
      }
      command = BuildCommand.new point, building
      world.push command
      tile = world.map.get point
      tile.should be_a(ConstructionSiteTile)
      world.run 10
      tile = world.map.get point
      tile.should be_a(BuildingTile)
    end

    it "should restrict building if not enought resources" do
      world = World.new create_map_2x2
      point = Point.new 1, 0
      building = Building.new Building::Type::StartPoint, **{
        construction: Construction.new(
          ts: 10,
          cost: ResourceBag.new({
            Resource::Type::Crystals => 100,
          })
        ),
      }
      command = BuildCommand.new point, building
      expect_raises(NotEnoughtResources) do
        world.push(command)
      end
    end
  end
end
