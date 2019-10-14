struct Game::Point
  property x : Int32
  property y : Int32

  def initialize(@x : Int32, @y : Int32)
  end

  getter x
  getter y

  def distance(other) : Int32
    (other.x - @x).abs + (other.y - @y).abs
  end
end
