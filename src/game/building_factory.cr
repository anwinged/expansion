module Game
  class BuildingFactory
    def initialize
      @items = [] of NamedTuple(t: Building::Type, b: Building)

      add(
        Building.new Building::Type::StartPoint, storage: 100
      )

      add(
        Building.new Building::Type::CrystalMiner, **{
          mining: Mining.new(
            ts: 20,
            dep: Deposit::Span.new(Resources::Type::Crystals, 40)
          ),
        }
      )

      add(
        Building.new Building::Type::CrystalRestorer, **{
          construction: Construction.new(
            ts: 30,
            cost: Resources.new({
              Resources::Type::Crystals => 100,
            }),
            requirements: [] of Game::Building::Type
          ),
          restoration: Mining.new(
            ts: 30,
            dep: Deposit::Span.new(Resources::Type::Crystals, 20)
          ),
        }
      )

      add(
        Building.new Building::Type::Terraformer, **{
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
