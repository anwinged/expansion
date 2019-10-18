module Game
  class BuildingFactory
    def initialize
      @items = [] of NamedTuple(t: Building::Type, b: Building)

      add(
        Building.new Building::Type::StartPoint, **{
          shortcut: "sp",
          storage:  100,
          roles:    [Building::Role::Storehouse],
        }
      )

      add(
        Building.new Building::Type::CrystalMiner, **{
          shortcut:     "miner",
          construction: Construction.new(
            ts: 30,
            cost: ResourceBag.new,
            requirements: [] of Game::Building::Type
          ),
          mining: Mining.new(
            ts: 20,
            resource: Resource.new(Resource::Type::Crystals, 40),
            input: ResourceBag.new
          ),
        }
      )

      add(
        Building.new Building::Type::CrystalRestorer, **{
          shortcut:     "rest",
          construction: Construction.new(
            ts: 45,
            cost: ResourceBag.new({
              Resource::Type::Crystals => 100,
            }),
            requirements: [] of Game::Building::Type
          ),
          restoration: Mining.new(
            ts: 30,
            resource: Resource.new(Resource::Type::Crystals, 20),
            input: ResourceBag.new
          ),
        }
      )

      add(
        Building.new Building::Type::OxygenCollector, **{
          shortcut:     "oxygen",
          construction: Construction.new(
            ts: 60,
            cost: ResourceBag.new({Resource::Type::Crystals => 200}),
            requirements: [] of Game::Building::Type
          ),
          mining: Mining.new(
            ts: 30,
            resource: Resource.new(Resource::Type::Oxygen, 10),
            input: ResourceBag.new({Resource::Type::Crystals => 5}),
            deposit: false
          ),
        }
      )

      add(
        Building.new Building::Type::Terraformer, **{
          shortcut:     "terr",
          construction: Construction.new(
            ts: 120,
            cost: ResourceBag.new({
              Resource::Type::Crystals => 300,
            }),
            requirements: [] of Game::Building::Type
          ),
          production: Production.new(
            ts: 60,
            input: ResourceBag.new({
              Resource::Type::Crystals => 50,
              Resource::Type::Oxygen   => 20,
            }),
            output: ResourceBag.new({
              Resource::Type::Terraformation => 5,
            })
          ),
        }
      )
    end

    getter items

    private def add(building : Building)
      t = building.type
      @items << {t: t, b: building}
    end
  end
end
