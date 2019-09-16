require "spec"
require "./../src/map"
require "./../src/queue"

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

describe App::Queue do
  q = App::Queue(Int32).new
  q.push(0, 1)
  q.push(10, 2)
  q.push(5, 3)
  item = q.pop(50)
  item.nil?.should be_falsey
end
