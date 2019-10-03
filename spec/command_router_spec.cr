require "./spec_helper"
require "../src/cli/*"

describe CLI::CommandRouter do
  it "should handle simple command" do
    router = CLI::CommandRouter.new
    x = 10
    router.add "plus" do
      x += 5
    end
    router.handle "plus"
    x.should eq 15
  end
end
