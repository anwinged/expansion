module Game
  class BaseException < Exception
  end

  class NotEnoughtResources < BaseException
  end

  class InvalidPlaceForBuilding < BaseException
  end
end
