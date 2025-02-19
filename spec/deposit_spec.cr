require "./spec_helper"

module Game::Test
  describe Deposit do
    it "should be created fulfilled" do
      dep = Deposit.new(Resource::Type::Crystals, 100)
      dep.cap.should eq 100
      dep.cur.should eq 100
    end

    it "can be created partially filled" do
      dep = Deposit.new(Resource::Type::Crystals, 100, 20)
      dep.cap.should eq 100
      dep.cur.should eq 20
    end

    it "should be decreased with span" do
      dep = Deposit.new(Resource::Type::Crystals, 100)
      res = dep.dec 20
      dep.cap.should eq 100
      dep.cur.should eq 80
      res.should eq 20
    end

    it "should not be increased above capacity" do
      dep = Deposit.new(Resource::Type::Crystals, 100, 20)
      res = dep.inc 100
      dep.cap.should eq 100
      dep.cur.should eq 100
      res.should eq 80
    end

    it "should not be decreased below zero" do
      dep = Deposit.new(Resource::Type::Crystals, 100)
      res = dep.dec 120
      dep.cap.should eq 100
      dep.cur.should eq 0
      res.should eq 100
    end
  end
end
