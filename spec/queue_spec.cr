require "./spec_helper"

module Game::TestQueue
  macro define_dummy_classes(count)
    {% for i in (1...count) %}
      class DummyCommand{{ i }} < Command
        def start(world) : TimeSpan
        end

        def finish(world)
        end

        def desc : String
          ""
        end
      end
    {% end %}
  end

  define_dummy_classes(5)

  describe Queue do
    it "should pop nil on empty queue" do
      queue = Queue.new
      item = queue.pop(50)
      item.should be_nil
    end

    it "should pop command on one element queue" do
      queue = Queue.new
      queue.push(10, DummyCommand1.new)
      item = queue.pop(50)
      item.nil?.should be_false
      item.as(Queue::Item).ts.should eq 10
      item.as(Queue::Item).command.should be_a(DummyCommand1)
    end

    it "should pop commands in proper order" do
      queue = Queue.new
      queue.push(10, DummyCommand1.new)
      queue.push(50, DummyCommand2.new)
      queue.push(30, DummyCommand3.new)
      item1 = queue.pop(100)
      item1.as(Queue::Item).command.should be_a(DummyCommand1)
      item2 = queue.pop(100)
      item2.as(Queue::Item).command.should be_a(DummyCommand3)
      item3 = queue.pop(100)
      item3.as(Queue::Item).command.should be_a(DummyCommand2)
    end
  end
end
