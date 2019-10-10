require "./spec_helper"

describe Game::Point do
  p1 = Game::Point.new(0, 0)
  p2 = Game::Point.new(5, 5)
  it "can calc distance" do
    p1.distance(p2).should eq 10
  end
  it "can calc reverse destance" do
    p2.distance(p1).should eq 10
  end
end
