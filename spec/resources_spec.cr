require "./spec_helper"

module Game::TestResourceBag
  alias Res = ResourceBag
  alias ResType = Resource::Type

  describe ResourceBag do
    it "should be created from hash" do
      res = Res.new({ResType::Crystals => 100})
      res[ResType::Crystals].should eq 100
    end

    it "should check single type" do
      res = Res.new({ResType::Crystals => 100})
      res.has(ResType::Crystals, 100).should be_true
    end

    it "should check resource bag" do
      res = Res.new({ResType::Crystals => 100})
      res.has({ResType::Crystals => 50}).should be_true
      res.has({ResType::Crystals => 150}).should be_false
    end

    it "should check empty value" do
      res = Res.new
      res.has({ResType::Crystals => 50}).should be_false
    end

    it "should inc single value" do
      res = Res.new ({ResType::Crystals => 10})
      res.inc ResType::Crystals, 5
      res[ResType::Crystals].should eq 15
    end

    it "should inc resource" do
      res = Res.new ({ResType::Crystals => 10})
      res.inc Resource.new(ResType::Crystals, 5)
      res[ResType::Crystals].should eq 15
    end

    it "should inc hash" do
      res = Res.new ({ResType::Crystals => 10})
      res.inc ({ResType::Crystals => 5})
      res[ResType::Crystals].should eq 15
    end

    it "should inc other bag" do
      res = Res.new ({ResType::Crystals => 10})
      res.inc Res.new({ResType::Crystals => 5})
      res[ResType::Crystals].should eq 15
    end
  end
end
