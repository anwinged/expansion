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
        storage: 200,
        roles: [Building::Role::Storehouse]
      )
    )
    map.set DepositTile.new(
      Point.new(1, 1),
      Deposit.new(Resource::Type::Crystals, 1000, 500)
    )
    map.set DepositTile.new(
      Point.new(1, 0),
      Deposit.new(Resource::Type::Crystals, 1000, 0)
    )
    map.set BuildingTile.new(
      Point.new(0, 1),
      Building.new(
        Building::Type::CrystalMiner,
        mining: Mining.new(
          ts: 20,
          resource: Resource.new(Resource::Type::Crystals, 40),
          input: ResourceBag.new
        ),
        restoration: Mining.new(
          ts: 20,
          resource: Resource.new(Resource::Type::Crystals, 40),
          input: ResourceBag.new({Resource::Type::Crystals => 5})
        ),
        production: Production.new(
          ts: 20,
          input: ResourceBag.new({Resource::Type::Crystals => 40}),
          output: ResourceBag.new({Resource::Type::Terraformation => 20})
        )
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
      command = MineCommand.new Point.new(0, 1), once: true
      time_point = (20 + 1 * 2 + 1 * 2).to_i64
      done_at = world.push command
      done_at.should eq time_point
      world.run time_point
      # Check world resources
      world.resources[Resource::Type::Crystals].should eq 40
      # Check tile deposit
      tile = world.map.get(1, 1).as(DepositTile)
      tile.dep.cur.should eq 460
    end

    it "should complete restore command" do
      world = World.new create_map_with_resource
      world.resources.inc(Resource::Type::Crystals, 20)
      command = RestoreCommand.new Point.new(0, 1), once: true
      time_point = (20 + 2 * 2 + 1 * 2).to_i64
      done_at = world.push command
      done_at.should eq time_point
      world.run time_point
      # Check world resources
      world.resources[Resource::Type::Crystals].should eq 15
      # Check tile deposit
      tile = world.map.get(1, 0).as(DepositTile)
      tile.dep.cur.should eq 40
    end

    it "should complete produce command" do
      world = World.new create_map_with_resource
      world.resources.inc(Resource::Type::Crystals, 100)
      command = ProduceCommand.new Point.new(0, 1), once: true
      time_point = (20 + 1 * 2 + 1 * 2).to_i64
      done_at = world.push command
      done_at.should eq time_point
      world.run time_point
      # Check world resources
      world.resources[Resource::Type::Crystals].should eq 60
      world.resources[Resource::Type::Terraformation].should eq 20
    end
  end
end
