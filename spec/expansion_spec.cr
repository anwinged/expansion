require "./spec_helper"
require "./../src/game/map"
require "./../src/game/queue"

describe Point do
  p1 = Point.new(0, 0)
  p2 = Point.new(5, 5)
  it "can calc distance" do
    p1.distance(p2).should eq 10
  end
  it "can calc reverse destance" do
    p2.distance(p1).should eq 10
  end
end
