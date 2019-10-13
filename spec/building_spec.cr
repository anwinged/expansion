require "./spec_helper"

describe Game::Building do
  it "should create storehouse" do
    bg = Game::Building.new Game::Building::Type::Storehouse, storage: 100
    bg.storage.should eq 100
  end

  it "should create crystal miner" do
    bg = Game::Building.new Game::Building::Type::CrystalMiner, **{
      production: Game::Production.new(
        ts: 20,
        input: Game::ResourceBag.new,
        output: Game::ResourceBag.new({
          Game::Resource::Type::Crystals => 100,
        })
      ),
    }
    bg.production.as(Game::Production).ts.should eq 20
  end
end
