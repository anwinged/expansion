module Game
  class BuildingList
    def initialize
      @items = [] of NamedTuple(t: Building::Type, b: Building)

      add(
        Building.new Building::Type::StartPoint, "Start Point", storage: 100
      )

      add(
        Building.new Building::Type::CrystalMiner, "Crystal Miner", **{
          production: Production.new(
            ts: 20,
            input: Resources.new,
            output: Resources.new({
              Resources::Type::Crystals => 100,
            })
          ),
        }
      )

      add(
        Building.new Building::Type::CrystalRestorer, **{
          cost: Resources.new({
            Resources::Type::Crystals => 100,
          }),
          restoration: Restoration.new(
            ts: 30,
            type: Resources::Type::Crystals,
            cap: 50
          ),
        }
      )
    end

    private def add(building : Building)
      t = building.type
      @items << {t: t, b: building}
    end
  end
end
