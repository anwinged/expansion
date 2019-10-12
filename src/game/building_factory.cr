module Game
  class BuildingFactory
    def initialize
      @items = [] of NamedTuple(t: Building::Type, b: Building)

      add(
        Building.new Building::Type::StartPoint, "Start", storage: 100
      )

      add(
        Building.new Building::Type::CrystalMiner, "Miner", **{
          mining: Production.new(
            ts: 20,
            input: Resources.new,
            res: Resources::Type::Crystals,
            cap: 40,
          ),
        }
      )

      add(
        Building.new Building::Type::CrystalRestorer, "Restorer", **{
          construction: Construction.new(
            ts: 30,
            cost: Resources.new({
              Resources::Type::Crystals => 100,
            }),
            requirements: [] of Game::Building::Type
          ),
          restoration: Restoration.new(
            ts: 30,
            input: Resources.new,
            res: Resources::Type::Crystals,
            cap: 20
          ),
        }
      )

      add(
        Building.new Building::Type::Terraformer, "Terraformator", **{
          construction: Construction.new(
            ts: 120,
            cost: Resources.new({
              Resources::Type::Crystals => 300,
            }),
            requirements: [] of Game::Building::Type
          ),
          production: Production.new(
            ts: 60,
            input: Resources.new({
              Resources::Type::Crystals => 50,
            }),
            output: Resources.new({
              Resources::Type::Terraformation => 5,
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
