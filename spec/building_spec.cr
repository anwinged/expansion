require "./spec_helper"

module Game::TestBuilding
  describe Building do
    it "should create storehouse" do
      bg = Building.new Building::Type::StartPoint, storage: 100
      bg.storage.should eq 100
    end

    it "should create crystal miner" do
      bg = Building.new Building::Type::CrystalMiner, **{
        production: Production.new(
          ts: 20,
          input: ResourceBag.new,
          output: ResourceBag.new({
            Resource::Type::Crystals => 100,
          })
        ),
      }
      bg.production.as(Production).ts.should eq 20
    end
  end
end
