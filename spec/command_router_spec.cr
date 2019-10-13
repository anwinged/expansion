require "./spec_helper"

module CLI::TestCommandRouter
  describe CommandRouter do
    it "should handle simple command as block" do
      router = CommandRouter.new
      x = 10
      router.add "plus" do |p|
        x += 5
      end
      router.handle "plus"
      x.should eq 15
    end

    it "should handle simple command as proc" do
      router = CommandRouter.new
      x = 10
      cb = ->(params : Hash(String, String)) { x += 5 }
      router.add "plus", &cb
      router.handle "plus"
      x.should eq 15
    end

    it "should handle command with argument" do
      router = CommandRouter.new
      x = 10
      router.add "plus {x}" do |params|
        x += params["x"].to_i32
      end
      router.handle "plus 5"
      x.should eq 15
    end

    it "should handle command with three arguments" do
      router = CommandRouter.new
      x = 0
      router.add "plus {x} {y} {z}" do |p|
        x = p["x"].to_i32 + p["y"].to_i32 + p["z"].to_i32
      end
      router.handle "plus 1 3 6"
      x.should eq 10
    end

    it "should match commands from begin of string" do
      router = CommandRouter.new
      x = 5
      router.add "plus" do |p|
        x += 10
      end
      router.add "mult and plus" do |p|
        x = x * 2 + 10
      end
      router.handle "mult and plus"
      x.should eq 20
    end
  end
end
