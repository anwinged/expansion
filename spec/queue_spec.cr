require "./spec_helper"
require "./../src/game/queue"
require "./../src/game/command"

macro define_dummy_classes(count)
  {% for i in (1...count) %}
    class Test::DummyCommand{{ i }} < Game::Command
      def start(world) : Int32
      end

      def finish(world)
      end
    end
  {% end %}
end

define_dummy_classes(5)

describe App::Queue do
  it "should pop nil on empty queue" do
    queue = App::Queue.new
    item = queue.pop(50)
    item.should be_nil
  end

  it "should pop command on one element queue" do
    queue = App::Queue.new
    queue.push(10, Test::DummyCommand1.new)
    item = queue.pop(50)
    item.nil?.should be_false
    item.as(App::Queue::Item).ts.should eq 10
    item.as(App::Queue::Item).command.should be_a(Test::DummyCommand1)
  end

  it "should pop commands in proper order" do
    queue = App::Queue.new
    queue.push(10, Test::DummyCommand1.new)
    queue.push(50, Test::DummyCommand2.new)
    queue.push(30, Test::DummyCommand3.new)
    item1 = queue.pop(100)
    item1.as(App::Queue::Item).command.should be_a(Test::DummyCommand1)
    item2 = queue.pop(100)
    item2.as(App::Queue::Item).command.should be_a(Test::DummyCommand3)
    item3 = queue.pop(100)
    item3.as(App::Queue::Item).command.should be_a(Test::DummyCommand2)
  end
end
