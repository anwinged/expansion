require "./spec_helper"

describe Game::Resources do
  it "should be created from hash" do
    res = Game::Resources.new({Game::Resources::Type::Crystals => 100})
    res[Game::Resources::Type::Crystals].should eq 100
  end
end
