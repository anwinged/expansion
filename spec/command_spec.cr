require "./spec_helper"

module Game::TestCommand
  extend self

  def create_empty_map_2x2 : Map
    Map.new 2, 2
  end

  def create_map_with_resource : Map
    map = Map.new 2, 2
    map.set BuildingTile.new(
      Point.new(0, 0),
      Building.new(
        Building::Type::StartPoint,
        storage: 200
      )
    )
    map.set DepositTile.new(
      Point.new(1, 1),
      Deposit.new(Resource::Type::Crystals, 100)
    )
    map.set BuildingTile.new(
      Point.new(0, 1),
      Building.new(
        Building::Type::CrystalMiner,
        mining: Mining.new(20, Resource.new(Resource::Type::Crystals, 40))
      )
    )
    map
  end

  describe Command do
    it "should complete build command" do
      world = World.new create_empty_map_2x2
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
      world = World.new create_empty_map_2x2
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

    it "should complete mining command" do
      world = World.new create_map_with_resource
      command = MineCommand.new Point.new(0, 1)
      world.push command
      world.run 20
      world.resources[Resource::Type::Crystals].should eq 40
    end
  end
end
